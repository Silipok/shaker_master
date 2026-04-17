import 'package:meta/meta.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.username});

  final String username;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthAuthenticated && other.username == username;
  }

  @override
  int get hashCode => username.hashCode;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
