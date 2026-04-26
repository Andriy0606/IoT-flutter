import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:my_project/data/local/key_value_storage.dart';

abstract interface class MqttTemperatureService {
  Future<void> connect();
  Future<void> disconnect();
  Stream<String> watchTemperature();
}

enum MqttBroker { hiveMq, mosquitto }

extension MqttBrokerX on MqttBroker {
  String get persistValue => switch (this) {
    MqttBroker.hiveMq => 'hivemq',
    MqttBroker.mosquitto => 'mosquitto',
  };

  String get label => switch (this) {
    MqttBroker.hiveMq => 'HiveMQ (broker.hivemq.com)',
    MqttBroker.mosquitto => 'EMQX (broker.emqx.io)',
  };

  static MqttBroker fromPersisted(String? value) {
    return switch (value) {
      'mosquitto' => MqttBroker.mosquitto,
      _ => MqttBroker.hiveMq,
    };
  }
}

abstract interface class SwitchableMqttTemperatureService
    implements MqttTemperatureService {
  Future<void> init();
  MqttBroker get broker;
  Stream<MqttBroker> watchBroker();
  Future<void> setBroker(MqttBroker broker);
}

final class MqttTemperatureServiceImpl implements MqttTemperatureService {
  MqttTemperatureServiceImpl({
    required String host,
    required String clientId,
    required String topic,
    int port = 1883,
    Duration connectTimeout = const Duration(seconds: 6),
  }) : _topic = topic,
       _host = host,
       _port = port,
       _connectTimeout = connectTimeout,
       _client = MqttServerClient(host, clientId) {
    _client.port = port;
    _client.keepAlivePeriod = 20;
    _client.logging(on: false);
  }

  final String _topic;
  final String _host;
  final int _port;
  final Duration _connectTimeout;
  final MqttServerClient _client;

  final StreamController<String> _temp = StreamController<String>.broadcast();

  bool _isConnected = false;
  bool _listening = false;

  @override
  Stream<String> watchTemperature() => _temp.stream;

  @override
  Future<void> connect() async {
    if (_isConnected) return;
    _dlog(
      'inner.connect start host=$_host port=$_port '
      'clientId=${_client.clientIdentifier}',
    );

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(_client.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client.connectionMessage = connMessage;

    try {
      await _client.connect().timeout(_connectTimeout);
    } catch (_) {
      _client.disconnect();
      _dlog('inner.connect error host=$_host port=$_port');
      rethrow;
    }

    if (_client.connectionStatus?.state != MqttConnectionState.connected) {
      _client.disconnect();
      throw StateError('MQTT not connected');
    }

    _isConnected = true;
    _dlog('inner.connect ok, subscribe topic=$_topic');
    _client.subscribe(_topic, MqttQos.atMostOnce);

    if (!_listening) {
      _listening = true;
      _client.updates?.listen((events) {
        if (events.isEmpty) return;
        final rec = events.first.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          rec.payload.message,
        );
        _dlog('inner.recv topic=$_topic payload=$payload');
        if (!_temp.isClosed) _temp.add(payload);
      });
      _dlog('inner.updates listener attached');
    }
  }

  @override
  Future<void> disconnect() async {
    if (!_isConnected) return;
    _isConnected = false;
    _dlog('inner.disconnect host=$_host port=$_port');
    _client.disconnect();
  }
}

final class SwitchableMqttTemperatureServiceImpl
    implements SwitchableMqttTemperatureService {
  SwitchableMqttTemperatureServiceImpl({
    required KeyValueStorage storage,
    required String topic,
    required String clientIdPrefix,
    String hiveHost = 'broker.hivemq.com',
    int hivePort = 1883,
    String mosquittoHost = 'broker.emqx.io',
    int mosquittoPort = 1883,
  }) : _storage = storage,
       _topic = topic,
       _clientIdPrefix = clientIdPrefix,
       _hiveHost = hiveHost,
       _hivePort = hivePort,
       _mosquittoHost = mosquittoHost,
       _mosquittoPort = mosquittoPort;

  static const String _kBrokerPref = 'mqtt_broker';

  final KeyValueStorage _storage;
  final String _topic;
  final String _clientIdPrefix;
  final String _hiveHost;
  final int _hivePort;
  final String _mosquittoHost;
  final int _mosquittoPort;

  final StreamController<String> _temp = StreamController<String>.broadcast();
  final StreamController<MqttBroker> _brokerEvents =
      StreamController<MqttBroker>.broadcast();

  MqttBroker _broker = MqttBroker.hiveMq;
  bool _initialized = false;

  MqttTemperatureServiceImpl? _inner;
  StreamSubscription<String>? _innerSub;

  Future<void> _serial = Future<void>.value();
  int _opId = 0;

  Future<void>? _initFuture;

  @override
  MqttBroker get broker => _broker;

  @override
  Stream<MqttBroker> watchBroker() => _brokerEvents.stream;

  @override
  Stream<String> watchTemperature() => _temp.stream;

  @override
  Future<void> init() {
    return _initFuture ??= _initImpl();
  }

  Future<void> _initImpl() async {
    if (_initialized) return;
    _dlog('init start');
    final persisted = await _storage.readString(_kBrokerPref);
    _broker = MqttBrokerX.fromPersisted(persisted);
    _initialized = true;
    _brokerEvents.add(_broker);
    _dlog('init done broker=$_broker');
  }

  @override
  Future<void> connect() {
    return _enqueue('connect', _connectUnlocked);
  }

  Future<void> _connectUnlocked() async {
    _dlog('_connectUnlocked start broker=$_broker');
    await init();
    final inner = _inner ??= _buildInner(_broker);
    try {
      await inner.connect();
    } catch (_) {
      // Ensure we don't keep a broken client instance around.
      await inner.disconnect();
      _inner = null;
      rethrow;
    }

    // Always (re)attach forwarding subscription in case a previous connect
    // attempt failed before we started listening.
    _innerSub?.cancel();
    _innerSub = inner.watchTemperature().listen((value) {
      _dlog('forward payload=$value');
      if (!_temp.isClosed) _temp.add(value);
    });
    _dlog('_connectUnlocked done broker=$_broker');
  }

  @override
  Future<void> disconnect() {
    return _enqueue('disconnect', _disconnectUnlocked);
  }

  Future<void> _disconnectUnlocked() async {
    _dlog('disconnect op start');
    _innerSub?.cancel();
    _innerSub = null;
    await _inner?.disconnect();
    _inner = null;
    _dlog('disconnect op done');
  }

  @override
  Future<void> setBroker(MqttBroker broker) {
    return _enqueue('setBroker($broker)', () async {
      _dlog('setBroker op start current=$_broker target=$broker');
      await init();
      if (broker == _broker) return;

      await _disconnectUnlocked();

      _broker = broker;
      await _storage.writeString(_kBrokerPref, broker.persistValue);
      _brokerEvents.add(_broker);

      // Ensure UI doesn't wait forever on a flaky network.
      await _connectUnlocked().timeout(const Duration(seconds: 8));
      _dlog('setBroker op done now=$_broker');
    });
  }

  MqttTemperatureServiceImpl _buildInner(MqttBroker broker) {
    switch (broker) {
      case MqttBroker.hiveMq:
        return MqttTemperatureServiceImpl(
          host: _hiveHost,
          port: _hivePort,
          clientId: '${_clientIdPrefix}_hive',
          topic: _topic,
        );
      case MqttBroker.mosquitto:
        return MqttTemperatureServiceImpl(
          host: _mosquittoHost,
          port: _mosquittoPort,
          clientId: '${_clientIdPrefix}_mosquitto',
          topic: _topic,
        );
    }
  }

  Future<void> _enqueue(String name, Future<void> Function() op) {
    final int id = ++_opId;
    final DateTime queuedAt = DateTime.now();
    bool started = false;
    _dlog('enqueue#$id $name');

    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!started) {
        final waitMs = DateTime.now().difference(queuedAt).inMilliseconds;
        _dlog('WARN enqueue#$id $name waiting ${waitMs}ms');
      }
    });

    // IMPORTANT:
    // Keep the queue moving even if a previous op failed. Without this,
    // `_serial` would stay completed with an error and all future `.then(...)`
    // callbacks would be skipped forever, causing "infinite loading" in UI.
    _serial = _serial
        .catchError((Object e, StackTrace st) {
          _dlog('prev-op-error: $e');
          _dlog(st.toString());
        })
        .then((_) async {
          started = true;
          final waitMs = DateTime.now().difference(queuedAt).inMilliseconds;
          _dlog('start#$id $name waited ${waitMs}ms');
          final sw = Stopwatch()..start();
          Timer? longRunTimer;
          longRunTimer = Timer(const Duration(seconds: 10), () {
            _dlog('WARN run#$id $name running >10s');
          });
          try {
            await op();
            longRunTimer.cancel();
            _dlog('done#$id $name ${sw.elapsedMilliseconds}ms');
          } catch (e, st) {
            longRunTimer.cancel();
            _dlog('err#$id $name ${sw.elapsedMilliseconds}ms $e');
            _dlog(st.toString());
            rethrow;
          }
        });
    return _serial;
  }
}

void _dlog(String message) {
  // Keep logs visible in `flutter run` output.
  // This is intentionally plain `print` (not `dart:developer log`) because
  // some run targets don't surface developer logs by default.
  // ignore: avoid_print
  print('[MQTT] $message');
}
