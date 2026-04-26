import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_project/app/di.dart';
import 'package:my_project/domain/services/mqtt_temperature_service.dart';

mixin HomeMqttMixin<T extends StatefulWidget> on State<T> {
  bool hasInternet = true;
  String? mqttTemp;
  bool _mqttStarted = false;
  MqttBroker broker = AppDi.mqttTemperatureService.broker;

  StreamSubscription<bool>? _internetSub;
  StreamSubscription<String>? _mqttSub;
  StreamSubscription<MqttBroker>? _brokerSub;

  Future<void> bootstrapMqtt() async {
    final online = await AppDi.connectivityService.hasInternet();
    if (!mounted) return;

    setState(() => hasInternet = online);

    await AppDi.mqttTemperatureService.init();
    if (!mounted) return;

    setState(() => broker = AppDi.mqttTemperatureService.broker);

    _brokerSub?.cancel();
    _brokerSub = AppDi.mqttTemperatureService.watchBroker().listen((b) {
      if (!mounted) return;
      setState(() {
        broker = b;
        mqttTemp = null;
      });
    });

    if (!online) {
      _showOfflineSnack();
    } else {
      await _startMqtt();
    }

    _internetSub = AppDi.connectivityService.watchInternet().listen((isOnline) {
      if (!mounted) return;
      final wasOnline = hasInternet;
      setState(() => hasInternet = isOnline);

      if (!isOnline && wasOnline) {
        _showOfflineSnack();
      }
      if (isOnline && !_mqttStarted) {
        _startMqtt();
      }
    });
  }

  void disposeMqtt() {
    _internetSub?.cancel();
    _mqttSub?.cancel();
    _brokerSub?.cancel();
  }

  void _showOfflineSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offline mode: MQTT disabled.')),
    );
  }

  Future<void> _startMqtt() async {
    if (_mqttStarted) return;
    _mqttStarted = true;

    try {
      await AppDi.mqttTemperatureService.init();
      await AppDi.mqttTemperatureService.connect();
    } catch (_) {
      if (!mounted) return;
      setState(() => _mqttStarted = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('MQTT connection failed.')));
      return;
    }

    _mqttSub = AppDi.mqttTemperatureService.watchTemperature().listen((value) {
      if (!mounted) return;
      setState(() => mqttTemp = value);
    });
  }
}
