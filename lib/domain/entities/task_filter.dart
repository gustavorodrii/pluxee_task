import 'task_status.dart';

class TaskFilter {
  final TaskStatus? status;
  final DateTime? from;
  final DateTime? to;

  const TaskFilter({this.status, this.from, this.to});

  bool get isEmpty => status == null && from == null && to == null;
}
