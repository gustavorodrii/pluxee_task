import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../domain/entities/task_status.dart';
import 'auth_api.dart';
import 'task_api.dart';

/// Implementação mock para rodar o front sem backend.
/// Mantém contrato igual aos APIs reais.
class MockApi implements AuthApi, TaskApi {
  final _uuid = const Uuid();
  final SecureStorage _storage = SecureStorage();

  final List<Map<String, dynamic>> _tasks = [
    {
      'id': 't1',
      'title': 'Revisar PR do módulo de pagamentos',
      'description': 'Olhar testes, edge cases e padronização.',
      'due_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'status': 'in_progress',
    },
    {
      'id': 't2',
      'title': 'Atualizar documentação do BLoC',
      'description': 'Adicionar exemplos de uso com go_router.',
      'due_date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      'status': 'pending',
    },
  ];

  // -------- AuthApi

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final token = 'mock_jwt_token_${_uuid.v4()}';
    await _storage.write(AppConstants.jwtKey, token);
    return {
      'token': token,
      'user': {'id': 'u1', 'name': 'Dev Mock', 'email': email},
    };
  }

  @override
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final token = 'mock_jwt_token_${_uuid.v4()}';
    await _storage.write(AppConstants.jwtKey, token);
    return {
      'token': token,
      'user': {'id': 'u1', 'name': name, 'email': email},
    };
  }

  @override
  Future<Map<String, dynamic>> me() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final token = await _storage.read(AppConstants.jwtKey);
    if (token == null) throw Exception('Sem token');
    return {
      'user': {'id': 'u1', 'name': 'Dev Mock', 'email': 'mock@demo.com'},
    };
  }

  @override
  Future<void> logout() async {
    await _storage.delete(AppConstants.jwtKey);
  }

  // -------- TaskApi

  @override
  Future<List<Map<String, dynamic>>> list(Map<String, dynamic> params) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final status = params['status'] as String?;
    final from = params['from'] as String?;
    final to = params['to'] as String?;
    DateTime? dFrom = from != null ? DateTime.tryParse(from) : null;
    DateTime? dTo = to != null ? DateTime.tryParse(to) : null;

    return _tasks.where((t) {
      final ts = t['status'] as String;
      if (status != null && ts != status) return false;
      final due = t['due_date'] != null ? DateTime.parse(t['due_date']) : null;
      if (dFrom != null && (due == null || due.isBefore(dFrom))) return false;
      if (dTo != null && (due == null || due.isAfter(dTo))) return false;
      return true;
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final task = Map<String, dynamic>.from(body);
    task['id'] = _uuid.v4();
    task['status'] = task['status'] ?? TaskStatus.pending.apiValue;
    _tasks.insert(0, task);
    return task;
  }

  @override
  Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> body) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _tasks.indexWhere((e) => e['id'] == id);
    if (idx == -1) throw Exception('Task não encontrada');
    _tasks[idx] = {..._tasks[idx], ...body};
    return _tasks[idx];
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tasks.removeWhere((e) => e['id'] == id);
  }

  @override
  Future<Map<String, dynamic>> toggleDone(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _tasks.indexWhere((e) => e['id'] == id);
    if (idx == -1) throw Exception('Task não encontrada');
    final current = _tasks[idx]['status'] as String;
    final next = current == 'done' ? 'pending' : 'done';
    _tasks[idx]['status'] = next;
    return _tasks[idx];
  }
}
