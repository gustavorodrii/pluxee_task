import 'package:equatable/equatable.dart';
import 'task_status.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskStatus status;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.status = TaskStatus.pending,
  });

  bool get isDone => status == TaskStatus.done;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        dueDate: json['due_date'] == null
            ? null
            : DateTime.parse(json['due_date'] as String),
        status: TaskStatusX.fromString(json['status'] as String? ?? 'pending'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'due_date': dueDate?.toIso8601String(),
        'status': status.apiValue,
      };

  @override
  List<Object?> get props => [id, title, status];
}
