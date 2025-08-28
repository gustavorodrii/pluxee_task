import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task.dart';
import 'status_chip.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleDone;

  const TaskCard(
      {super.key, required this.task, this.onTap, this.onToggleDone});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description?.isNotEmpty == true)
              Text(task.description!,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusChip(status: task.status),
                  if (task.dueDate != null)
                    Text('Vence: ${df.format(task.dueDate!)}'),
                ]),
          ],
        ),
        trailing: Checkbox(
            value: task.isDone, onChanged: (_) => onToggleDone?.call()),
      ),
    );
  }
}
