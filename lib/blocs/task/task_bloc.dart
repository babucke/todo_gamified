// lib/blocs/task/task_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'task_event.dart';
import 'task_state.dart';
import '../../repositories/task_repository.dart';
import '../../models/task_model.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;

  TaskBloc({required this.taskRepository}) : super(TaskInitialState()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoadingState());
    try {
      final tasks = await taskRepository.getTasks(event.userId);
      emit(TaskLoadedState(tasks: tasks));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
    }
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.addTask(event.task);
      emit(TaskAddedState(task: event.task));
      // Nach dem Hinzufügen die Aufgaben neu laden
      add(LoadTasksEvent(userId: event.task.assignedTo));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.updateTask(event.task);
      emit(TaskUpdatedState(task: event.task));
      // Nach dem Aktualisieren die Aufgaben neu laden
      add(LoadTasksEvent(userId: event.task.assignedTo));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.deleteTask(event.taskId);
      emit(TaskDeletedState(taskId: event.taskId));
      // Nach dem Löschen die Aufgaben neu laden
      add(LoadTasksEvent(userId: event.userId));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
    }
  }
}
