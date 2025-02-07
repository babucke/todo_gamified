// lib/blocs/task/task_event.dart

import 'package:equatable/equatable.dart';
import '../../models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  final String userId;

  const LoadTasksEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddTaskEvent extends TaskEvent {
  final TaskModel task;

  const AddTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final TaskModel task;

  const UpdateTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;
  final String userId;

  const DeleteTaskEvent({required this.taskId, required this.userId});

  @override
  List<Object?> get props => [taskId, userId];
}

class CompleteTaskEvent extends TaskEvent {
  final TaskModel task;

  const CompleteTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

class ApproveTaskEvent extends TaskEvent {
  final TaskModel task;

  const ApproveTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

class UploadProofPhotoEvent extends TaskEvent {
  final TaskModel task;
  final String photoUrl;

  const UploadProofPhotoEvent({required this.task, required this.photoUrl});

  @override
  List<Object?> get props => [task, photoUrl];
}

class UncompleteTaskEvent extends TaskEvent {
  final TaskModel task;

  const UncompleteTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];
}
