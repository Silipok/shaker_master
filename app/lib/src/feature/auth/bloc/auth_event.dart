import 'package:meta/meta.dart';

@immutable
sealed class AuthEvent {
  const AuthEvent();
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.username, required this.password});

  final String username;
  final String password;
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}
