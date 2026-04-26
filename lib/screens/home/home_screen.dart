import 'package:flutter/material.dart';

import 'package:my_project/app/app_routes.dart';
import 'package:my_project/app/di.dart';
import 'package:my_project/domain/models/room_snapshot.dart';
import 'package:my_project/screens/home/home_mqtt_mixin.dart';
import 'package:my_project/widgets/app_scaffold.dart';
import 'package:my_project/widgets/broker_status_card.dart';
import 'package:my_project/widgets/metric_card.dart';
import 'package:my_project/widgets/metrics_grid.dart';
import 'package:my_project/widgets/offline_banner.dart';
import 'package:my_project/widgets/room_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with HomeMqttMixin<HomeScreen> {
  int _roomIndex = 0;
  late Future<List<RoomSnapshot>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _roomsFuture = AppDi.roomRepository.fetchRooms();
    bootstrapMqtt();
  }

  @override
  void dispose() {
    disposeMqtt();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Room State'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
          ),
        ],
      ),
      child: FutureBuilder<List<RoomSnapshot>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          final rooms = snapshot.data ?? const <RoomSnapshot>[];
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Failed to load rooms from API.'),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _roomsFuture = AppDi.roomRepository.fetchRooms();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (rooms.isEmpty) {
            return const Center(child: Text('No cached room data yet.'));
          }

          final safeIndex = _roomIndex.clamp(0, rooms.length - 1);
          final room = rooms[safeIndex];
          final canGoPrev = safeIndex > 0;
          final canGoNext = safeIndex < rooms.length - 1;

          final temperatureValue = hasInternet
              ? (mqttTemp ?? '${room.temperatureC}°C')
              : '${room.temperatureC}°C';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BrokerStatusCard(broker: broker, mqttTemp: mqttTemp),
              ),
              if (!hasInternet)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: OfflineBanner(),
                ),
              RoomHeader(
                roomName: room.name,
                canGoPrev: canGoPrev,
                canGoNext: canGoNext,
                onPrev: () => setState(() => _roomIndex = safeIndex - 1),
                onNext: () => setState(() => _roomIndex = safeIndex + 1),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: MetricsGrid(
                  children: <Widget>[
                    MetricCard(
                      label: 'Temperature',
                      value: temperatureValue,
                      icon: Icons.thermostat,
                    ),
                    MetricCard(
                      label: 'Humidity',
                      value: '${room.humidityPercent}%',
                      icon: Icons.water_drop,
                    ),
                    MetricCard(
                      label: 'Light',
                      value: room.isLightOn ? 'ON' : 'OFF',
                      icon: room.isLightOn
                          ? Icons.lightbulb
                          : Icons.lightbulb_outline,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
