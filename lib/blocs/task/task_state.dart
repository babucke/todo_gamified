// lib/blocs/task/task_state.dart
import 'package:equatable/equatable.dart';
import '../../models/task_model.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

// Initialer Zustand
class TaskInitialState extends TaskState {}

// Zustand beim Laden der Aufgaben
class TaskLoadingState extends TaskState {}

// Zustand, wenn Aufgaben erfolgreich geladen wurden
class TaskLoadedState extends TaskState {
  final List<TaskModel> tasks;

  const TaskLoadedState({required this.tasks});

  @override
  List<Object?> get props => [tasks];
}

// Zustand bei einem Fehler
class TaskErrorState extends TaskState {
  final String message;

  const TaskErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// Zustand nach dem Hinzufügen einer Aufgabe
class TaskAddedState extends TaskState {
  final TaskModel task;

  const TaskAddedState({required this.task});

  @override
  List<Object?> get props => [task];
}

// Zustand nach dem Aktualisieren einer Aufgabe
class TaskUpdatedState extends TaskState {
  final TaskModel task;

  const TaskUpdatedState({required this.task});

  @override
  List<Object?> get props => [task];
}

// Zustand nach dem Löschen einer Aufgabe
class TaskDeletedState extends TaskState {
  final String taskId;

  const TaskDeletedState({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}
