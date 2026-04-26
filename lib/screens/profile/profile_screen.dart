import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/app/app_routes.dart';
import 'package:my_project/domain/services/mqtt_temperature_service.dart';
import 'package:my_project/screens/profile/profile_edit_form.dart';
import 'package:my_project/state/mqtt/mqtt_cubit.dart';
import 'package:my_project/state/mqtt/mqtt_state.dart';
import 'package:my_project/state/user/user_cubit.dart';
import 'package:my_project/state/user/user_state.dart';
import 'package:my_project/widgets/app_scaffold.dart';
import 'package:my_project/widgets/section_card.dart';
import 'package:my_project/widgets/user_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Profile')),
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, userState) {
          if (userState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userState.user;

          return ListView(
            children: <Widget>[
              UserHeader(
                title: user?.name ?? 'No user',
                subtitle: user?.email ?? '',
                trailing: OutlinedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final cubit = context.read<UserCubit>();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Log out?'),
                          content: const Text(
                            'You will need to sign in again to continue.',
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Log out'),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmed != true) return;
                    await cubit.deleteLocalUser();
                    if (!context.mounted) return;
                    navigator.pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text('Log out'),
                ),
              ),
              const SizedBox(height: 16),
              const ProfileEditForm(),
              const SizedBox(height: 12),
              BlocBuilder<MqttCubit, MqttState>(
                builder: (context, mqtt) {
                  return SectionCard(
                    title: 'MQTT',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Active broker',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Expanded(child: Text(mqtt.broker.label)),
                            if (mqtt.isSwitchingBroker) ...<Widget>[
                              const SizedBox(width: 12),
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Use EMQX'),
                          subtitle: const Text(
                            'Switches broker with reconnect',
                          ),
                          value: mqtt.broker == MqttBroker.mosquitto,
                          onChanged: mqtt.isSwitchingBroker
                              ? null
                              : (_) => context.read<MqttCubit>().toggleBroker(),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              SectionCard(
                title: 'Danger zone',
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Delete local user',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final cubit = context.read<UserCubit>();
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete user?'),
                              content: const Text(
                                'This will remove your saved account from the '
                                'device.',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmed != true) return;
                        await cubit.deleteLocalUser();
                        if (!context.mounted) return;
                        navigator.pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text('Delete'),
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
