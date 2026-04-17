import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shaker_master/src/feature/auth/bloc/auth_event.dart';
import 'package:shaker_master/src/feature/auth/bloc/auth_state.dart';
import 'package:shaker_master/src/feature/auth/data/auth_repository.dart';

final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onStatusChecked);
  }

  final AuthRepository _repository;

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final username = await _repository.login(event.username, event.password);
      emit(AuthAuthenticated(username: username));
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _repository.logout();
      emit(const AuthUnauthenticated());
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _onStatusChecked(AuthStatusChecked event, Emitter<AuthState> emit) async {
    try {
      final isAuthenticated = await _repository.isAuthenticated();
      if (isAuthenticated) {
        final username = await _repository.getUsername();
        emit(AuthAuthenticated(username: username ?? 'User'));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }
}
