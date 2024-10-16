// lib/blocs/task/task_event.dart
import 'package:equatable/equatable.dart';
import '../../models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

// Event zum Laden der Aufgaben
class LoadTasksEvent extends TaskEvent {
  final String userId;

  const LoadTasksEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Event zum Hinzufügen einer neuen Aufgabe
class AddTaskEvent extends TaskEvent {
  final TaskModel task;

  const AddTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

// Event zum Aktualisieren einer Aufgabe
class UpdateTaskEvent extends TaskEvent {
  final TaskModel task;

  const UpdateTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

// Event zum Löschen einer Aufgabe
class DeleteTaskEvent extends TaskEvent {
  final String taskId;
  final String userId; // Hinzugefügt

  const DeleteTaskEvent({required this.taskId, required this.userId});

  @override
  List<Object?> get props => [taskId, userId];
}
