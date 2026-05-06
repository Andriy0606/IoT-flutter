import 'package:my_project/domain/services/mqtt_temperature_service.dart';

final class MqttState {
  const MqttState({
    required this.hasInternet,
    required this.broker,
    required this.temperature,
    required this.isSwitchingBroker,
    required this.errorMessage,
  });

  factory MqttState.initial(MqttBroker broker) {
    return MqttState(
      hasInternet: true,
      broker: broker,
      temperature: null,
      isSwitchingBroker: false,
      errorMessage: null,
    );
  }

  final bool hasInternet;
  final MqttBroker broker;
  final String? temperature;
  final bool isSwitchingBroker;
  final String? errorMessage;

  MqttState copyWith({
    bool? hasInternet,
    MqttBroker? broker,
    String? temperature,
    bool? isSwitchingBroker,
    String? errorMessage,
  }) {
    return MqttState(
      hasInternet: hasInternet ?? this.hasInternet,
      broker: broker ?? this.broker,
      temperature: temperature ?? this.temperature,
      isSwitchingBroker: isSwitchingBroker ?? this.isSwitchingBroker,
      errorMessage: errorMessage,
    );
  }
}
