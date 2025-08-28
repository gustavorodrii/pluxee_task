import 'package:equatable/equatable.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.token,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? token;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, token, errorMessage];
}
