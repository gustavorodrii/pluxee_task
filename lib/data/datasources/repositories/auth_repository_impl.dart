import '../../../core/constants/app_constants.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/result.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../api/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _api;
  final SecureStorage _storage;

  AuthRepositoryImpl(this._api, this._storage);

  @override
  Future<Result<User>> login(
      {required String email, required String password}) async {
    try {
      final data = await _api.login(email, password);
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      return Ok(user);
    } catch (e) {
      return Err('Falha no login: $e');
    }
  }

  @override
  Future<Result<User>> register(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final data = await _api.register(name, email, password);
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      return Ok(user);
    } catch (e) {
      return Err('Falha no cadastro: $e');
    }
  }

  @override
  Future<void> logout() => _api.logout();

  @override
  Future<User?> currentUser() async {
    try {
      final data = await _api.me();
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> hasToken() async =>
      (await _storage.read(AppConstants.jwtKey)) != null;
}
