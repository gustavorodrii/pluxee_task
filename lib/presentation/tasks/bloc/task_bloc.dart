import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/result.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_filter.dart';
import '../../../domain/repositories/task_repository.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _repo;

  TaskBloc(this._repo) : super(const TaskState()) {
    on<TasksRequested>(_onLoad);
    on<TaskCreated>(_onCreate);
    on<TaskUpdated>(_onUpdate);
    on<TaskDeleted>(_onDelete);
    on<TaskToggled>(_onToggle);
    on<TaskFilterChanged>(_onFilter);
  }

  Future<void> _onLoad(TasksRequested event, Emitter<TaskState> emit) async {
    emit(state.copyWith(loading: true));
    final res = await _repo.list(filter: event.filter ?? state.filter);
    switch (res) {
      case Ok<List<Task>> ok:
        emit(state.copyWith(
            loading: false,
            tasks: ok.value,
            filter: event.filter ?? state.filter));
      case Err<List<Task>> err:
        emit(state.copyWith(loading: false, error: err.message));
    }
  }

  Future<void> _onCreate(TaskCreated event, Emitter<TaskState> emit) async {
    emit(state.copyWith(actionInProgress: true));
    final res = await _repo.create(event.task);
    switch (res) {
      case Ok<Task> ok:
        final list = [ok.value, ...state.tasks];
        emit(state.copyWith(actionInProgress: false, tasks: list));
      case Err<Task> err:
        emit(state.copyWith(actionInProgress: false, error: err.message));
    }
  }

  Future<void> _onUpdate(TaskUpdated event, Emitter<TaskState> emit) async {
    emit(state.copyWith(actionInProgress: true));
    final res = await _repo.update(event.task);
    switch (res) {
      case Ok<Task> ok:
        final list =
            state.tasks.map((t) => t.id == ok.value.id ? ok.value : t).toList();
        emit(state.copyWith(actionInProgress: false, tasks: list));
      case Err<Task> err:
        emit(state.copyWith(actionInProgress: false, error: err.message));
    }
  }

  Future<void> _onDelete(TaskDeleted event, Emitter<TaskState> emit) async {
    emit(state.copyWith(actionInProgress: true));
    final res = await _repo.delete(event.id);
    switch (res) {
      case Ok<void> _:
        final list = state.tasks.where((t) => t.id != event.id).toList();
        emit(state.copyWith(actionInProgress: false, tasks: list));
      case Err<void> err:
        emit(state.copyWith(actionInProgress: false, error: err.message));
    }
  }

  Future<void> _onToggle(TaskToggled event, Emitter<TaskState> emit) async {
    final res = await _repo.toggleDone(event.id);
    switch (res) {
      case Ok<Task> ok:
        final list =
            state.tasks.map((t) => t.id == ok.value.id ? ok.value : t).toList();
        emit(state.copyWith(tasks: list));
        add(TasksRequested()); // refetch respeitando state.filter

      case Err<Task> err:
        emit(state.copyWith(error: err.message));
    }
  }

  Future<void> _onFilter(
      TaskFilterChanged event, Emitter<TaskState> emit) async {
    add(TasksRequested(filter: event.filter));
  }
}
