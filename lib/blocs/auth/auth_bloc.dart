import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:complaint_app/blocs/auth/auth_event.dart';
import 'package:meta/meta.dart';

import '../../repositories/auth_repo.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.register(event.registerModel);

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(AuthSuccess(event.registerModel.email));
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Registration failed';
        emit(AuthFailure(errorMessage));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}