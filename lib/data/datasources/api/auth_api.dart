import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/secure_storage.dart';

class AuthApi {
  final Dio _dio;
  final SecureStorage _storage;

  AuthApi(this._dio, this._storage);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio
        .post('/auth/login', data: {'email': email, 'password': password});
    final data = res.data as Map<String, dynamic>;
    final token = data['token'] as String;
    await _storage.write(AppConstants.jwtKey, token);
    return data;
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final res = await _dio.post('/auth/register',
        data: {'name': name, 'email': email, 'password': password});
    final data = res.data as Map<String, dynamic>;
    final token = data['token'] as String;
    await _storage.write(AppConstants.jwtKey, token);
    return data;
  }

  Future<Map<String, dynamic>> me() async {
    final token = await _storage.read(AppConstants.jwtKey);
    final res = await _dio.get('/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    return res.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _storage.delete(AppConstants.jwtKey);
  }
}
