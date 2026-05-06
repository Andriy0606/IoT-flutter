import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/app/session_storage.dart';
import 'package:my_project/domain/common/result.dart';
import 'package:my_project/domain/models/user.dart';
import 'package:my_project/domain/repositories/user_repository.dart';
import 'package:my_project/domain/validation/validators.dart';
import 'package:my_project/state/user/user_state.dart';

final class UserCubit extends Cubit<UserState> {
  UserCubit({
    required UserRepository userRepository,
    required AuthValidators validators,
    required SessionStorage sessionStorage,
  }) : _userRepository = userRepository,
       _validators = validators,
       _sessionStorage = sessionStorage,
       super(const UserState.initial());

  final UserRepository _userRepository;
  final AuthValidators _validators;
  final SessionStorage _sessionStorage;

  Future<void> loadUser() async {
    emit(state.copyWith(isLoading: true));
    final user = await _userRepository.readUser();
    emit(state.copyWith(isLoading: false, user: user));
  }

  Future<void> saveUser({
    required String name,
    required String email,
    required String password,
  }) async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true));

    final validation = _validators.validateRegister(
      name: name,
      email: email,
      password: password,
    );
    if (validation is Err<void>) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: validation.failure.message,
        ),
      );
      return;
    }

    final updated = User(
      name: name.trim(),
      email: email.trim(),
      password: password,
    );
    await _userRepository.saveUser(updated);
    emit(state.copyWith(isSaving: false, user: updated));
  }

  Future<void> deleteLocalUser() async {
    await _userRepository.deleteUser();
    await _sessionStorage.logout();
    emit(state.copyWith(user: null));
  }
}
