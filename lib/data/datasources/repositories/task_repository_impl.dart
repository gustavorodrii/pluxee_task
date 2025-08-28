import '../../../core/utils/result.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_filter.dart';
import '../../../domain/repositories/task_repository.dart';
import '../task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _ds;
  TaskRepositoryImpl(this._ds);

  @override
  Future<Result<List<Task>>> list({TaskFilter? filter}) async {
    try {
      final items = await _ds.fetchTasks(filter: filter);
      return Ok(items);
    } catch (e) {
      return Err('Erro ao carregar tarefas: $e');
    }
  }

  @override
  Future<Result<Task>> create(Task task) async {
    try {
      final t = await _ds.create(task);
      return Ok(t);
    } catch (e) {
      return Err('Erro ao criar: $e');
    }
  }

  @override
  Future<Result<Task>> update(Task task) async {
    try {
      final t = await _ds.update(task);
      return Ok(t);
    } catch (e) {
      return Err('Erro ao atualizar: $e');
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _ds.delete(id);
      return const Ok(null);
    } catch (e) {
      return Err('Erro ao excluir: $e');
    }
  }

  @override
  Future<Result<Task>> toggleDone(String id) async {
    try {
      final t = await _ds.toggleDone(id);
      return Ok(t);
    } catch (e) {
      return Err('Erro ao marcar como concluída: $e');
    }
  }
}
