import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/domain/services/connectivity_service.dart';
import 'package:my_project/domain/services/mqtt_temperature_service.dart';
import 'package:my_project/state/mqtt/mqtt_state.dart';

final class MqttCubit extends Cubit<MqttState> {
  MqttCubit({
    required ConnectivityService connectivity,
    required SwitchableMqttTemperatureService mqtt,
  }) : _connectivity = connectivity,
       _mqtt = mqtt,
       super(MqttState.initial(mqtt.broker));

  final ConnectivityService _connectivity;
  final SwitchableMqttTemperatureService _mqtt;

  StreamSubscription<bool>? _internetSub;
  StreamSubscription<String>? _tempSub;
  StreamSubscription<MqttBroker>? _brokerSub;

  bool _started = false;

  Future<void> init() async {
    if (_started) return;
    _started = true;

    final online = await _connectivity.hasInternet();
    emit(state.copyWith(hasInternet: online, broker: _mqtt.broker));

    await _mqtt.init();
    emit(state.copyWith(broker: _mqtt.broker));

    _brokerSub?.cancel();
    _brokerSub = _mqtt.watchBroker().listen((b) {
      emit(state.copyWith(broker: b));
    });

    if (online) {
      await _connectAndListen();
    }

    _internetSub?.cancel();
    _internetSub = _connectivity.watchInternet().listen((isOnline) {
      emit(state.copyWith(hasInternet: isOnline));
      if (isOnline) {
        _connectAndListen();
      }
    });
  }

  Future<void> toggleBroker() async {
    if (state.isSwitchingBroker) return;
    final target = state.broker == MqttBroker.mosquitto
        ? MqttBroker.hiveMq
        : MqttBroker.mosquitto;

    emit(state.copyWith(isSwitchingBroker: true));
    try {
      await _mqtt.setBroker(target);
      emit(state.copyWith(isSwitchingBroker: false));
    } catch (e) {
      emit(
        state.copyWith(isSwitchingBroker: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _connectAndListen() async {
    try {
      await _mqtt.connect();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return;
    }

    _tempSub?.cancel();
    _tempSub = _mqtt.watchTemperature().listen((value) {
      emit(state.copyWith(temperature: value));
    });
  }

  @override
  Future<void> close() async {
    await _internetSub?.cancel();
    await _tempSub?.cancel();
    await _brokerSub?.cancel();
    return super.close();
  }
}
