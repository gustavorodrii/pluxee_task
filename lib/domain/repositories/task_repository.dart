import '../../core/utils/result.dart';
import '../entities/task.dart';
import '../entities/task_filter.dart';

abstract class TaskRepository {
  Future<Result<List<Task>>> list({TaskFilter? filter});
  Future<Result<Task>> create(Task task);
  Future<Result<Task>> update(Task task);
  Future<Result<void>> delete(String id);
  Future<Result<Task>> toggleDone(String id);
}
