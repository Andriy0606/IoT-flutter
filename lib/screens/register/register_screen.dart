import 'package:flutter/material.dart';
import 'package:my_project/app/app_routes.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/auth_footer_link.dart';
import 'package:my_project/widgets/primary_button.dart';
import 'package:my_project/widgets/app_scaffold.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = TextEditingController();
    final email = TextEditingController();
    final pass = TextEditingController();

    return AppScaffold(
      appBar: AppBar(title: const Text('Register')),
      maxWidth: 420,
      child: ListView(
        children: <Widget>[
          const SizedBox(height: 12),
          const Text('Create your account'),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Name',
            hint: 'John Doe',
            controller: name,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Email',
            hint: 'you@mail.com',
            controller: email,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Password',
            obscure: true,
            controller: pass,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Create account',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.login,
              );
            },
          ),
          const SizedBox(height: 8),
          AuthFooterLink(
            prompt: 'Already have an account?',
            actionText: 'Sign in',
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.login,
              );
            },
          ),
        ],
      ),
    );
  }
}
