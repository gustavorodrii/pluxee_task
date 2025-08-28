import '../../core/utils/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login({required String email, required String password});
  Future<Result<User>> register(
      {required String name, required String email, required String password});
  Future<void> logout();
  Future<User?> currentUser();
  Future<bool> hasToken();
}
