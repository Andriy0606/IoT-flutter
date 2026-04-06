import 'package:flutter/material.dart';

import 'package:my_project/app/app_routes.dart';
import 'package:my_project/widgets/app_scaffold.dart';
import 'package:my_project/widgets/section_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Profile')),
      child: ListView(
        children: <Widget>[
          const _Header(),
          const SizedBox(height: 16),
          const SectionCard(
            title: 'Account',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _Line(title: 'Name', value: 'John Doe'),
                SizedBox(height: 8),
                _Line(title: 'Email', value: 'john@doe.dev'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SectionCard(
            title: 'Preferences',
            child: _Line(title: 'Theme', value: 'System'),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const CircleAvatar(radius: 28, child: Icon(Icons.person)),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('John Doe'),
            SizedBox(height: 2),
            Text('john@doe.dev'),
          ],
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (Route<dynamic> route) => false,
            );
          },
          child: const Text('Log out'),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final muted = style?.copyWith(color: Colors.grey[600]);

    return Row(
      children: <Widget>[
        Expanded(child: Text(title, style: muted)),
        Text(value, style: style),
      ],
    );
  }
}
