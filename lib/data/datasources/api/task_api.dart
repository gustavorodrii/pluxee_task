import 'package:dio/dio.dart';

abstract class TaskApi {
  Future<List<Map<String, dynamic>>> list(Map<String, dynamic> params);
  Future<Map<String, dynamic>> create(Map<String, dynamic> body);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> body);
  Future<void> delete(String id);
  Future<Map<String, dynamic>> toggleDone(String id);
}

class TaskApiImpl implements TaskApi {
  final Dio _dio;
  TaskApiImpl(this._dio);

  @override
  Future<List<Map<String, dynamic>>> list(Map<String, dynamic> params) async {
    final r = await _dio.get('/tasks', queryParameters: params);
    return List<Map<String, dynamic>>.from(r.data as List);
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final r = await _dio.post('/tasks', data: body);
    return Map<String, dynamic>.from(r.data);
  }

  @override
  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> body) async {
    final r = await _dio.put('/tasks/$id', data: body);
    return Map<String, dynamic>.from(r.data);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete('/tasks/$id');
  }

  @override
  Future<Map<String, dynamic>> toggleDone(String id) async {
    final r = await _dio.post('/tasks/$id/toggle');
    return Map<String, dynamic>.from(r.data);
  }
}
