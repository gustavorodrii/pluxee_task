import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_status.dart';

abstract class TaskRemoteDataSource {
  Future<List<Task>> fetchTasks({TaskFilter? filter});
  Future<Task> create(Task task);
  Future<Task> update(Task task);
  Future<void> delete(String id);
  Future<Task> toggleDone(String id);
}

const _kTasksKey = 'tasks_storage_v1';

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final bool useMock;
  TaskRemoteDataSourceImpl({this.useMock = false});

  Future<List<Task>> _loadList() async {
    final sp = await SharedPreferences.getInstance();
    final jsonStr = sp.getString(_kTasksKey);
    if (jsonStr == null || jsonStr.isEmpty) return <Task>[];
    final list = (jsonDecode(jsonStr) as List).cast<Map<String, dynamic>>();
    return list.map(Task.fromJson).toList();
  }

  Future<void> _saveList(List<Task> tasks) async {
    final sp = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await sp.setString(_kTasksKey, jsonStr);
  }

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();

  List<Task> _applyFilter(List<Task> items, TaskFilter? f) {
    if (f == null) return items;
    var out = items;

    if (f.status != null) {
      out = out.where((t) => t.status == f.status).toList();
    }

    if (f.from != null) {
      out = out.where((t) {
        final d = t.dueDate;
        return d == null ||
            !d.isBefore(DateTime(f.from!.year, f.from!.month, f.from!.day));
      }).toList();
    }
    if (f.to != null) {
      final toEnd =
          DateTime(f.to!.year, f.to!.month, f.to!.day, 23, 59, 59, 999);
      out = out.where((t) {
        final d = t.dueDate;
        return d == null || !d.isAfter(toEnd);
      }).toList();
    }

    out.sort((a, b) {
      final ad = a.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });

    return out;
  }

  @override
  Future<List<Task>> fetchTasks({TaskFilter? filter}) async {
    final items = await _loadList();
    return _applyFilter(items, filter);
  }

  @override
  Future<Task> create(Task task) async {
    final items = await _loadList();

    final newTask = task.copyWith(
      id: (task.id.isEmpty ? _genId() : task.id),
    );

    final list = [newTask, ...items];
    await _saveList(list);
    return newTask;
  }

  @override
  Future<Task> update(Task task) async {
    final items = await _loadList();
    final idx = items.indexWhere((t) => t.id == task.id);
    if (idx == -1) throw Exception('Task não encontrada');
    items[idx] = task;
    await _saveList(items);
    return task;
  }

  @override
  Future<void> delete(String id) async {
    final items = await _loadList();
    items.removeWhere((t) => t.id == id);
    await _saveList(items);
  }

  @override
  Future<Task> toggleDone(String id) async {
    final items = await _loadList();
    final idx = items.indexWhere((t) => t.id == id);
    if (idx == -1) throw Exception('Task não encontrada');

    final current = items[idx];
    final toggled = current.copyWith(
      status: current.status == TaskStatus.done
          ? TaskStatus.pending
          : TaskStatus.done,
    );

    items[idx] = toggled;
    await _saveList(items);
    return toggled;
  }
}
