import 'package:flutter_bloc/flutter_bloc.dart';
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
    on<CompleteTaskEvent>(_onCompleteTask);
    on<ApproveTaskEvent>(_onApproveTask);
    on<UploadProofPhotoEvent>(_onUploadProofPhoto);
    on<UncompleteTaskEvent>(_onUncompleteTask);
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
      add(LoadTasksEvent(userId: event.task.assignedBy));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.updateTask(event.task);
      add(LoadTasksEvent(userId: event.task.assignedBy));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.deleteTask(event.taskId);
      add(LoadTasksEvent(userId: event.userId));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
    }
  }

  Future<void> _onCompleteTask(CompleteTaskEvent event, Emitter<TaskState> emit) async {
    try {
      final updatedTask = event.task.copyWith(isCompleted: true);
      await taskRepository.updateTask(updatedTask);
      add(LoadTasksEvent(userId: event.task.assignedTo));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
    }
  }

  Future<void> _onApproveTask(ApproveTaskEvent event, Emitter<TaskState> emit) async {
    try {
      final updatedTask = event.task.copyWith(isApproved: true);
      await taskRepository.updateTask(updatedTask);
      add(LoadTasksEvent(userId: event.task.assignedBy));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
    }
  }

  Future<void> _onUploadProofPhoto(UploadProofPhotoEvent event, Emitter<TaskState> emit) async {
    try {
      final updatedTask = event.task.copyWith(proofPhotoUrl: event.photoUrl);
      await taskRepository.updateTask(updatedTask);
      add(LoadTasksEvent(userId: event.task.assignedTo));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
    }
  }

  Future<void> _onUncompleteTask(UncompleteTaskEvent event, Emitter<TaskState> emit) async {
    try {
      final updatedTask = event.task.copyWith(
        isCompleted: false,
        isApproved: false,
        proofPhotoUrl: null,  // Reset proof photo when uncompleting
      );
      await taskRepository.updateTask(updatedTask);
      add(LoadTasksEvent(userId: event.task.assignedTo));
    } catch (e) {
      emit(TaskErrorState(message: e.toString()));
    }
  }
}