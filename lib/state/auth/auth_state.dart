final class AuthState {
  const AuthState({
    required this.isLoading,
    required this.errorMessage,
    required this.isSuccess,
  });

  const AuthState.idle()
    : isLoading = false,
      errorMessage = null,
      isSuccess = false;

  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  static const Object _unset = Object();

  AuthState copyWith({
    bool? isLoading,
    Object? errorMessage = _unset,
    bool? isSuccess,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
