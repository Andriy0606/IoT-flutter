import 'package:flutter/material.dart';

import 'package:my_project/app/app_routes.dart';
import 'package:my_project/widgets/app_scaffold.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/auth_footer_link.dart';
import 'package:my_project/widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final pass = TextEditingController();

    return AppScaffold(
      appBar: AppBar(title: const Text('Login')),
      maxWidth: 420,
      child: ListView(
        children: <Widget>[
          const SizedBox(height: 12),
          const Text('Welcome back'),
          const SizedBox(height: 16),
          AppTextField(label: 'Email', hint: 'you@mail.com', controller: email),
          const SizedBox(height: 12),
          AppTextField(label: 'Password', obscure: true, controller: pass),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Sign in',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            },
          ),
          const SizedBox(height: 8),
          AuthFooterLink(
            prompt: 'No account?',
            actionText: 'Register',
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.register);
            },
          ),
        ],
      ),
    );
  }
}
