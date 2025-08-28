part of 'task_bloc.dart';

class TaskState extends Equatable {
  final List<Task> tasks;
  final TaskFilter? filter;
  final bool loading;
  final bool actionInProgress;
  final String? error;

  const TaskState({
    this.tasks = const [],
    this.filter,
    this.loading = false,
    this.actionInProgress = false,
    this.error,
  });

  TaskState copyWith({
    List<Task>? tasks,
    TaskFilter? filter,
    bool? loading,
    bool? actionInProgress,
    String? error,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      loading: loading ?? this.loading,
      actionInProgress: actionInProgress ?? this.actionInProgress,
      error: error,
    );
  }

  @override
  List<Object?> get props => [tasks, filter, loading, actionInProgress, error];
}
