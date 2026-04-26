import 'package:flutter/material.dart';
import 'package:my_project/domain/services/mqtt_temperature_service.dart';

class BrokerStatusCard extends StatelessWidget {
  const BrokerStatusCard({
    required this.broker,
    required this.mqttTemp,
    super.key,
  });

  final MqttBroker broker;
  final String? mqttTemp;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            const Icon(Icons.hub_outlined),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Broker: ${broker.label} • MQTT: ${mqttTemp ?? '—'}'),
            ),
          ],
        ),
      ),
    );
  }
}
