import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/state/user/user_cubit.dart';
import 'package:my_project/state/user/user_state.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/editable_section.dart';
import 'package:my_project/widgets/key_value_row.dart';

class ProfileEditForm extends StatefulWidget {
  const ProfileEditForm({super.key});

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  bool _isEditing = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _syncFromUser(UserState state) {
    final user = state.user;
    if (user == null) return;
    _name.text = user.name;
    _email.text = user.email;
    _pass.text = user.password;
  }

  void _toggleEdit(UserState state) {
    setState(() => _isEditing = !_isEditing);
    if (_isEditing) _syncFromUser(state);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        final user = state.user;
        return EditableSection(
          title: 'Account',
          isEditing: _isEditing,
          readChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              KeyValueRow(title: 'Name', value: user?.name ?? ''),
              const SizedBox(height: 8),
              KeyValueRow(title: 'Email', value: user?.email ?? ''),
            ],
          ),
          editChild: Column(
            children: <Widget>[
              AppTextField(label: 'Name', controller: _name),
              const SizedBox(height: 12),
              AppTextField(label: 'Email', controller: _email),
              const SizedBox(height: 12),
              AppTextField(label: 'Password', obscure: true, controller: _pass),
            ],
          ),
          footer: !_isEditing
              ? OutlinedButton(
                  onPressed: state.isLoading ? null : () => _toggleEdit(state),
                  child: const Text('Edit'),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    FilledButton(
                      onPressed: state.isSaving
                          ? null
                          : () async {
                              final cubit = context.read<UserCubit>();
                              final messenger = ScaffoldMessenger.of(context);

                              await cubit.saveUser(
                                name: _name.text,
                                email: _email.text,
                                password: _pass.text,
                              );
                              if (!mounted) return;
                              final error = cubit.state.errorMessage;
                              if (error == null) {
                                setState(() => _isEditing = false);
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Saved')),
                                );
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(content: Text(error)),
                                );
                              }
                            },
                      child: Text(state.isSaving ? 'Saving...' : 'Save'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _toggleEdit(state),
                      child: const Text('Cancel'),
                    ),
                    if (state.errorMessage != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}
