import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task_filter.dart';
import '../../../domain/entities/task_status.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_overlay.dart';
import '../../../widgets/task_card.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/task_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  TaskStatus? _status;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final res = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (res != null)
      setState(() {
        _from = res.start;
        _to = res.end;
      });
    _applyFilter();
  }

  void _applyFilter() {
    context.read<TaskBloc>().add(
        TaskFilterChanged(TaskFilter(status: _status, from: _from, to: _to)));
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () =>
                context.read<AuthBloc>().add(AuthLogoutRequested()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/dashboard/task/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nova'),
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listenWhen: (p, c) =>
            p.error != c.error || p.actionInProgress != c.actionInProgress,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            loading: state.loading || state.actionInProgress,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Filtro:'),
                      DropdownButton<TaskStatus?>(
                        value: _status,
                        hint: const Text('Status'),
                        onChanged: (v) {
                          setState(() => _status = v);
                          _applyFilter();
                        },
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(
                              value: TaskStatus.pending,
                              child: Text('Pendente')),
                          DropdownMenuItem(
                              value: TaskStatus.inProgress,
                              child: Text('Em andamento')),
                          DropdownMenuItem(
                              value: TaskStatus.done, child: Text('Concluída')),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickDateRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(_from == null
                            ? 'Período'
                            : '${df.format(_from!)} - ${df.format(_to!)}'),
                      ),
                      if (_from != null || _status != null)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _status = null;
                              _from = null;
                              _to = null;
                            });
                            _applyFilter();
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpar'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.tasks.isEmpty
                      ? EmptyState(
                          title: 'Nada por aqui',
                          subtitle:
                              'Crie sua primeira tarefa ou ajuste os filtros.',
                          action: OutlinedButton.icon(
                            onPressed: () => context.go('/dashboard/task/new'),
                            icon: const Icon(Icons.add),
                            label: const Text('Nova tarefa'),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, c) {
                            final grid = c.maxWidth > 900 ? 2 : 1;
                            if (grid == 1) {
                              return ListView.builder(
                                padding: const EdgeInsets.only(bottom: 88),
                                itemCount: state.tasks.length,
                                itemBuilder: (_, i) {
                                  final t = state.tasks[i];
                                  return TaskCard(
                                    task: t,
                                    onTap: () => context.go('/task/${t.id}'),
                                    onToggleDone: () => context
                                        .read<TaskBloc>()
                                        .add(TaskToggled(t.id)),
                                  );
                                },
                              );
                            } else {
                              return GridView.builder(
                                padding: const EdgeInsets.only(
                                    bottom: 88, left: 8, right: 8),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 3.2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: state.tasks.length,
                                itemBuilder: (_, i) {
                                  final t = state.tasks[i];
                                  return TaskCard(
                                    task: t,
                                    onTap: () => context.go('/task/${t.id}'),
                                    onToggleDone: () => context
                                        .read<TaskBloc>()
                                        .add(TaskToggled(t.id)),
                                  );
                                },
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
