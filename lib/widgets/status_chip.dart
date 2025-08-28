import 'package:flutter/material.dart';
import '../../domain/entities/task_status.dart';

class StatusChip extends StatelessWidget {
  final TaskStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TaskStatus.pending => Colors.orange,
      TaskStatus.inProgress => Colors.blue,
      TaskStatus.done => Colors.green,
    };
    return Chip(
      label: Text(status.label),
      backgroundColor: color.withOpacity(0.15),
      side: BorderSide(color: color),
    );
  }
}
