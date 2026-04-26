import 'package:my_project/domain/models/user.dart';

final class UserState {
  const UserState({
    required this.user,
    required this.isLoading,
    required this.isSaving,
    required this.errorMessage,
  });

  const UserState.initial()
    : user = null,
      isLoading = false,
      isSaving = false,
      errorMessage = null;

  final User? user;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  static const Object _unset = Object();

  UserState copyWith({
    Object? user = _unset,
    bool? isLoading,
    bool? isSaving,
    Object? errorMessage = _unset,
  }) {
    return UserState(
      user: user == _unset ? this.user : user as User?,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
