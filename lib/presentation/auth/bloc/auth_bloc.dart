import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../core/storage/secure_storage.dart'; // ajuste o caminho conforme seu projeto

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({SecureStorage? storage})
      : _storage = storage ?? SecureStorage(),
        super(const AuthState()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
  }

  final SecureStorage _storage;
  static const String _kTokenKey = 'jwt_token';

  Future<void> _onAppStarted(
      AuthAppStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final token = await _storage.read(_kTokenKey);
      if (token != null && token.isNotEmpty) {
        emit(state.copyWith(status: AuthStatus.authenticated, token: token));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLogin(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final token = 'mock-jwt-token';
      await _storage.write(_kTokenKey, token);
      emit(state.copyWith(status: AuthStatus.authenticated, token: token));
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.failure, errorMessage: e.toString()));
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onRegister(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    add(AuthLoginRequested(email: event.email, password: event.password));
  }

  Future<void> _onLogout(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _storage.delete(_kTokenKey);
    emit(state.copyWith(status: AuthStatus.unauthenticated, token: null));
  }
}
