import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_project/app/app_routes.dart';
import 'package:my_project/state/auth/auth_cubit.dart';
import 'package:my_project/state/auth/auth_state.dart';
import 'package:my_project/widgets/app_scaffold.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/auth_footer_link.dart';
import 'package:my_project/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await context.read<AuthCubit>().login(
      email: _email.text,
      password: _pass.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, next) => prev.isSuccess != next.isSuccess,
      listener: (context, state) {
        if (!state.isSuccess) return;
        context.read<AuthCubit>().reset();
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final errorText = state.errorMessage;
          return AppScaffold(
            appBar: AppBar(title: const Text('Login')),
            maxWidth: 420,
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 12),
                const Text('Welcome back'),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  hint: 'you@mail.com',
                  controller: _email,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Password',
                  obscure: true,
                  controller: _pass,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: state.isLoading ? 'Signing in...' : 'Sign in',
                  onPressed: state.isLoading ? null : _submit,
                ),
                if (errorText != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    errorText,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                AuthFooterLink(
                  prompt: 'No account?',
                  actionText: 'Register',
                  onTap: () {
                    context.read<AuthCubit>().reset();
                    Navigator.of(context).pushNamed(AppRoutes.register);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
