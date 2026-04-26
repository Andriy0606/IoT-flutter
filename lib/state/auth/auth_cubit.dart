import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/domain/common/result.dart';
import 'package:my_project/domain/services/auth_service.dart';
import 'package:my_project/state/auth/auth_state.dart';

final class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthService authService})
    : _authService = authService,
      super(const AuthState.idle());

  final AuthService _authService;

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(isLoading: true));
    final result = await _authService.login(email: email, password: password);
    if (result is Err<void>) {
      emit(
        state.copyWith(isLoading: false, errorMessage: result.failure.message),
      );
      return;
    }
    emit(state.copyWith(isLoading: false, errorMessage: null, isSuccess: true));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true));
    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
    );
    if (result is Err<void>) {
      emit(
        state.copyWith(isLoading: false, errorMessage: result.failure.message),
      );
      return;
    }
    emit(state.copyWith(isLoading: false, errorMessage: null, isSuccess: true));
  }

  void reset() => emit(const AuthState.idle());
}
