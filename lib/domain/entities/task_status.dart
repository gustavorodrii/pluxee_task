enum TaskStatus { pending, inProgress, done }

extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
        TaskStatus.pending => 'Pendente',
        TaskStatus.inProgress => 'Em andamento',
        TaskStatus.done => 'Concluída',
      };

  static TaskStatus fromString(String v) {
    switch (v) {
      case 'pending':
        return TaskStatus.pending;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.pending;
    }
  }

  String get apiValue => switch (this) {
        TaskStatus.pending => 'pending',
        TaskStatus.inProgress => 'in_progress',
        TaskStatus.done => 'done',
      };
}
