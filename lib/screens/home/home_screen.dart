import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/app/app_routes.dart';
import 'package:my_project/domain/models/room_snapshot.dart';
import 'package:my_project/state/mqtt/mqtt_cubit.dart';
import 'package:my_project/state/mqtt/mqtt_state.dart';
import 'package:my_project/state/rooms/rooms_cubit.dart';
import 'package:my_project/state/rooms/rooms_state.dart';
import 'package:my_project/widgets/app_scaffold.dart';
import 'package:my_project/widgets/broker_status_card.dart';
import 'package:my_project/widgets/metric_card.dart';
import 'package:my_project/widgets/metrics_grid.dart';
import 'package:my_project/widgets/offline_banner.dart';
import 'package:my_project/widgets/room_header.dart';
import 'package:torch_toggle_plugin/torch_toggle_plugin.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      child: BlocBuilder<RoomsCubit, RoomsState>(
        builder: (context, roomsState) {
          if (roomsState is RoomsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final (rooms, selectedIndex) = switch (roomsState) {
            RoomsLoaded(:final rooms, :final selectedIndex) => (
              rooms,
              selectedIndex,
            ),
            RoomsError(:final cachedRooms, :final selectedIndex) => (
              cachedRooms,
              selectedIndex,
            ),
            _ => (const <RoomSnapshot>[], 0),
          };

          if (rooms.isEmpty) {
            final msg = roomsState is RoomsError ? roomsState.message : null;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('No cached room data yet.'),
                    if (msg != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(msg, textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.read<RoomsCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final safeIndex = selectedIndex.clamp(0, rooms.length - 1);
          final room = rooms[safeIndex];
          final canGoPrev = safeIndex > 0;
          final canGoNext = safeIndex < rooms.length - 1;

          return BlocBuilder<MqttCubit, MqttState>(
            builder: (context, mqtt) {
              final temperatureValue = mqtt.hasInternet
                  ? (mqtt.temperature ?? '${room.temperatureC}°C')
                  : '${room.temperatureC}°C';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BrokerStatusCard(
                      broker: mqtt.broker,
                      mqttTemp: mqtt.temperature,
                    ),
                  ),
                  if (!mqtt.hasInternet)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: OfflineBanner(),
                    ),
                  RoomHeader(
                    roomName: room.name,
                    canGoPrev: canGoPrev,
                    canGoNext: canGoNext,
                    onPrev: () => context.read<RoomsCubit>().selectPrev(),
                    onNext: () => context.read<RoomsCubit>().selectNext(),
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
                        GestureDetector(
                          onLongPress: () async {
                            try {
                              final enabled = await TorchTogglePlugin.onLight();
                              if (!context.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    enabled ? 'Torch: ON' : 'Torch: OFF',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            } on PlatformException catch (e) {
                              if (!context.mounted) {
                                return;
                              }
                              await _showUnsupportedDialog(
                                context: context,
                                message: e.message ?? 'Not supported.',
                              );
                            }
                          },
                          child: MetricCard(
                            label: 'Light',
                            value: room.isLightOn ? 'ON' : 'OFF',
                            icon: room.isLightOn
                                ? Icons.lightbulb
                                : Icons.lightbulb_outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showUnsupportedDialog({
    required BuildContext context,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not supported'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
