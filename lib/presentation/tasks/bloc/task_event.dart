part of 'task_bloc.dart';

sealed class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TasksRequested extends TaskEvent {
  final TaskFilter? filter;
  TasksRequested({this.filter});
}

class TaskCreated extends TaskEvent {
  final Task task;
  TaskCreated(this.task);
}

class TaskUpdated extends TaskEvent {
  final Task task;
  TaskUpdated(this.task);
}

class TaskDeleted extends TaskEvent {
  final String id;
  TaskDeleted(this.id);
}

class TaskToggled extends TaskEvent {
  final String id;
  TaskToggled(this.id);
}

class TaskFilterChanged extends TaskEvent {
  final TaskFilter filter;
  TaskFilterChanged(this.filter);
}
