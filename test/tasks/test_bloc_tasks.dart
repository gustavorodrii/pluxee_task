// test/tasks/test_bloc_tasks.dart
import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Ajuste os imports abaixo conforme o "name:" do seu pubspec.yaml.
// Aqui assumimos que o nome do pacote é "pluxee".
import 'package:pluxee/presentation/tasks/bloc/task_bloc.dart';
import 'package:pluxee/domain/entities/task.dart';
import 'package:pluxee/domain/entities/task_filter.dart';
import 'package:pluxee/domain/entities/task_status.dart';
import 'package:pluxee/domain/repositories/task_repository.dart';
import 'package:pluxee/core/utils/result.dart';

/// ------------------------
/// STORAGE FAKE (SharedPreferences)
/// ------------------------

const _kTasksKey = 'tasks_storage_v1';

class _FakeLocalStore {
  Future<List<Task>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kTasksKey);
    if (raw == null || raw.isEmpty) return <Task>[];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Task.fromJson).toList();
  }

  Future<void> save(List<Task> items) async {
    final sp = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(items.map((e) => e.toJson()).toList());
    await sp.setString(_kTasksKey, jsonStr);
  }
}

/// ------------------------
/// REPOSITÓRIO FAKE (usa o storage acima)
/// ------------------------

class _InMemoryTaskRepo implements TaskRepository {
  final _FakeLocalStore _store;
  _InMemoryTaskRepo(this._store);

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();

  List<Task> _apply(List<Task> items, TaskFilter? f) {
    var out = List<Task>.from(items);

    if (f?.status != null) {
      out = out.where((t) => t.status == f!.status).toList();
    }

    if (f?.from != null) {
      final from = DateTime(f!.from!.year, f.from!.month, f.from!.day);
      out = out
          .where((t) => t.dueDate == null || !t.dueDate!.isBefore(from))
          .toList();
    }

    if (f?.to != null) {
      final toEnd =
          DateTime(f!.to!.year, f.to!.month, f.to!.day, 23, 59, 59, 999);
      out = out
          .where((t) => t.dueDate == null || !t.dueDate!.isAfter(toEnd))
          .toList();
    }

    // ordena por dueDate (mais recentes primeiro); nulos vão para o fim
    out.sort((a, b) =>
        (b.dueDate ?? DateTime(0)).compareTo(a.dueDate ?? DateTime(0)));
    return out;
  }

  @override
  Future<Result<List<Task>>> list({TaskFilter? filter}) async {
    try {
      final items = await _store.load();
      return Ok(_apply(items, filter));
    } catch (e) {
      return Err('Erro ao carregar: $e');
    }
  }

  @override
  Future<Result<Task>> create(Task task) async {
    try {
      final items = await _store.load();
      final withId = task.copyWith(id: task.id.isEmpty ? _genId() : task.id);
      await _store.save([withId, ...items]);
      return Ok(withId);
    } catch (e) {
      return Err('Erro ao criar: $e');
    }
  }

  @override
  Future<Result<Task>> update(Task task) async {
    try {
      final items = await _store.load();
      final i = items.indexWhere((t) => t.id == task.id);
      if (i == -1) throw Exception('Task não encontrada');
      items[i] = task;
      await _store.save(items);
      return Ok(task);
    } catch (e) {
      return Err('Erro ao atualizar: $e');
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      final items = await _store.load();
      items.removeWhere((t) => t.id == id);
      await _store.save(items);
      return const Ok(null);
    } catch (e) {
      return Err('Erro ao excluir: $e');
    }
  }

  @override
  Future<Result<Task>> toggleDone(String id) async {
    try {
      final items = await _store.load();
      final i = items.indexWhere((t) => t.id == id);
      if (i == -1) throw Exception('Task não encontrada');
      final cur = items[i];
      final toggled = cur.copyWith(
        status: cur.status == TaskStatus.done
            ? TaskStatus.pending
            : TaskStatus.done,
      );
      items[i] = toggled;
      await _store.save(items);
      return Ok(toggled);
    } catch (e) {
      return Err('Erro ao marcar como concluída: $e');
    }
  }
}

/// ------------------------
/// HELPERS
/// ------------------------

Task _t({
  String id = '',
  String title = 'Task',
  String? desc,
  DateTime? due,
  TaskStatus status = TaskStatus.pending,
}) {
  return Task(
    id: id,
    title: title,
    description: desc,
    dueDate: due,
    status: status,
  );
}

/// ------------------------
/// TESTES
/// ------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // zera o SharedPreferences antes de cada teste
    SharedPreferences.setMockInitialValues(<String, Object>{_kTasksKey: '[]'});
  });

  group('TaskBloc', () {
    late TaskBloc bloc;

    setUp(() {
      final repo = _InMemoryTaskRepo(_FakeLocalStore());
      bloc = TaskBloc(repo);
    });

    tearDown(() => bloc.close());

    blocTest<TaskBloc, TaskState>(
      'carrega lista vazia ao solicitar TasksRequested',
      build: () => bloc,
      act: (b) => b.add(TasksRequested()),
      expect: () => [
        // estado com loading = true
        predicate<TaskState>((s) => s.loading == true),
        // estado final com loading = false e lista vazia
        predicate<TaskState>((s) => s.loading == false && s.tasks.isEmpty),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'cria uma tarefa e ela aparece com id gerado (estado final)',
      build: () => bloc,
      act: (b) async {
        b.add(TasksRequested());
        await Future<void>.delayed(const Duration(milliseconds: 1));
        b.add(TaskCreated(_t(title: 'Estudar BLoC')));
      },
      wait: const Duration(milliseconds: 40),
      verify: (b) {
        expect(b.state.tasks, isNotEmpty);
        expect(b.state.tasks.first.title, 'Estudar BLoC');
        expect(b.state.tasks.first.id, isNotEmpty);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'toggle muda status pendente <-> done e persiste (estado final)',
      build: () => bloc,
      act: (b) async {
        b.add(TasksRequested());
        await Future<void>.delayed(const Duration(milliseconds: 1));
        b.add(TaskCreated(_t(title: 'Lavar o carro')));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        final id = b.state.tasks.first.id;
        b.add(TaskToggled(id));
      },
      wait: const Duration(milliseconds: 60),
      verify: (b) {
        expect(b.state.tasks, isNotEmpty);
        expect(b.state.tasks.first.title, 'Lavar o carro');
        expect(b.state.tasks.first.status, TaskStatus.done);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'aplica filtro por status=done em fev/2025 (estado final apenas)',
      build: () => bloc,
      act: (b) async {
        b.add(TasksRequested());
        await Future<void>.delayed(const Duration(milliseconds: 1));

        b.add(TaskCreated(_t(title: 'A', due: DateTime(2025, 1, 10))));
        b.add(TaskCreated(_t(title: 'B', due: DateTime(2025, 2, 15))));
        b.add(TaskCreated(_t(title: 'C', due: DateTime(2025, 3, 20))));
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final idB = b.state.tasks.firstWhere((x) => x.title == 'B').id;
        b.add(TaskToggled(idB));
        await Future<void>.delayed(const Duration(milliseconds: 5));

        b.add(TaskFilterChanged(TaskFilter(
          status: TaskStatus.done,
          from: DateTime(2025, 2, 1),
          to: DateTime(2025, 2, 28),
        )));
      },
      wait: const Duration(milliseconds: 100),
      verify: (b) {
        expect(b.state.filter?.status, TaskStatus.done);
        expect(b.state.tasks.length, 1);
        expect(b.state.tasks.first.title, 'B');
        expect(b.state.tasks.first.status, TaskStatus.done);
      },
    );
  });
}
