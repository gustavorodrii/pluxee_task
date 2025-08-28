import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_status.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../bloc/task_bloc.dart';
import 'package:go_router/go_router.dart';

class TaskFormPage extends StatefulWidget {
  final String? taskId;
  const TaskFormPage({super.key, this.taskId});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime? _due;
  TaskStatus _status = TaskStatus.pending;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.taskId != null) {
      final state = context.read<TaskBloc>().state;
      final t = state.tasks.firstWhere((e) => e.id == widget.taskId,
          orElse: () => const Task(id: '', title: ''));
      if (t.id.isNotEmpty) {
        _title.text = t.title;
        _description.text = t.description ?? '';
        _due = t.dueDate;
        _status = t.status;
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _due ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (date == null) return;
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_due ?? now));
    if (time == null) return;
    setState(() {
      _due = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _submit() {
    if (_form.currentState?.validate() != true) return;

    final task = Task(
      id: widget.taskId ?? '',
      title: _title.text.trim(),
      description:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      dueDate: _due,
      status: _status,
    );

    final bloc = context.read<TaskBloc>();

    if (widget.taskId == null) {
      bloc.add(TaskCreated(task));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa criada')),
      );
    } else {
      bloc.add(TaskUpdated(task));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa atualizada')),
      );
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.taskId == null ? 'Nova Tarefa' : 'Editar Tarefa')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField(
                        label: 'Título',
                        controller: _title,
                        validator: (v) => (v == null || v.trim().length < 3)
                            ? 'Informe o título'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Descrição (opcional)',
                        controller: _description,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<TaskStatus>(
                              value: _status,
                              decoration:
                                  const InputDecoration(labelText: 'Status'),
                              items: const [
                                DropdownMenuItem(
                                    value: TaskStatus.pending,
                                    child: Text('Pendente')),
                                DropdownMenuItem(
                                    value: TaskStatus.inProgress,
                                    child: Text('Em andamento')),
                                DropdownMenuItem(
                                    value: TaskStatus.done,
                                    child: Text('Concluída')),
                              ],
                              onChanged: (v) => setState(
                                  () => _status = v ?? TaskStatus.pending),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickDue,
                              icon: const Icon(Icons.date_range),
                              label: Text(_due == null
                                  ? 'Vencimento'
                                  : df.format(_due!)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<TaskBloc, TaskState>(
                        builder: (context, state) => AppButton(
                          label: widget.taskId == null ? 'Criar' : 'Salvar',
                          onPressed: state.actionInProgress ? null : _submit,
                          loading: state.actionInProgress,
                          icon: widget.taskId == null ? Icons.add : Icons.save,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
