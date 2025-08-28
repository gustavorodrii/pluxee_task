import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/status_chip.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/task_bloc.dart';
import 'package:go_router/go_router.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;
  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Tarefa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(AuthLogoutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          final task = state.tasks.firstWhere((t) => t.id == taskId,
              orElse: () => const Task(id: '', title: ''));
          if (task.id.isEmpty) {
            return const Center(child: Text('Tarefa não encontrada'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(task.title,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                StatusChip(status: task.status),
                const SizedBox(height: 8),
                if (task.dueDate != null)
                  Text('Vencimento: ${df.format(task.dueDate!)}'),
                const SizedBox(height: 16),
                Text(task.description ?? 'Sem descrição'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.go('/task/${task.id}/edit'),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await showConfirmDialog(context,
                            title: 'Excluir',
                            message: 'Confirma excluir esta tarefa?');
                        if (!ok) return;
                        // dispatch
                        // ignore: use_build_context_synchronously
                        context.read<TaskBloc>().add(TaskDeleted(task.id));
                        // ignore: use_build_context_synchronously
                        context.go('/dashboard');
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tarefa excluída')));
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Excluir'),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () =>
                          context.read<TaskBloc>().add(TaskToggled(task.id)),
                      icon: Icon(task.isDone
                          ? Icons.check_box
                          : Icons.check_box_outline_blank),
                      tooltip: 'Marcar concluída',
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
