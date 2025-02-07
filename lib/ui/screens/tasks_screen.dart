import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/task/task_state.dart';
import '../../models/task_model.dart';
import '../../utils/enums.dart';
import '../../localization.dart';
import '../../repositories/user_repository.dart';
import '../widgets/task_card.dart';
import 'create_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late String currentUserId;
  UserRole currentUserRole = UserRole.unknown;
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      currentUserId = currentUser.uid;
      _loadUserRoleAndTasks();
    } else {
      print('Kein authentifizierter Benutzer gefunden.');
    }
  }

  Future<void> _loadUserRoleAndTasks() async {
    try {
      UserRole role = await _userRepository.getUserRole(currentUserId);
      setState(() {
        currentUserRole = role;
      });
      _loadTasks();
    } catch (e) {
      print('Fehler beim Laden der Benutzerrolle: $e');
    }
  }

  void _loadTasks() {
    context.read<TaskBloc>().add(LoadTasksEvent(userId: currentUserId));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.tasks),
          bottom: TabBar(
            tabs: [
              Tab(text: AppLocalizations.of(context)!.openTasks),
              Tab(text: AppLocalizations.of(context)!.completedTasks),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTaskList(context, false), // Offene Aufgaben
            _buildTaskList(context, true),  // Erledigte Aufgaben
          ],
        ),
        floatingActionButton: currentUserRole == UserRole.parent
            ? FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateTaskScreen()),
            );
            if (result == true) {
              _loadTasks();
            }
          },
          child: Icon(Icons.add),
          tooltip: AppLocalizations.of(context)!.addTask,
        )
            : null,
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, bool showCompleted) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoadingState) {
          return Center(child: CircularProgressIndicator());
        } else if (state is TaskLoadedState) {
          var tasks = state.tasks;

          // Filtere die Tasks basierend auf dem Status
          tasks = tasks.where((task) => task.isCompleted == showCompleted).toList();

          // Für erledigte Aufgaben, zeige nur die letzten 10
          if (showCompleted) {
            tasks = tasks.take(10).toList();
          }

          if (tasks.isEmpty) {
            return Center(
              child: Text(showCompleted
                  ? AppLocalizations.of(context)!.noCompletedTasks
                  : AppLocalizations.of(context)!.noOpenTasks
              ),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                userRole: currentUserRole,
                onDelete: () {
                  context.read<TaskBloc>().add(
                    DeleteTaskEvent(taskId: task.id, userId: currentUserId),
                  );
                },
                onEdit: () async {
                  if (currentUserRole == UserRole.parent) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateTaskScreen(taskToEdit: task),
                      ),
                    );
                    if (result == true) {
                      _loadTasks();
                    }
                  }
                },
                onComplete: currentUserRole == UserRole.child && !task.isCompleted
                    ? () {
                  context.read<TaskBloc>().add(CompleteTaskEvent(task: task));
                }
                    : null,
                onUncomplete: currentUserRole == UserRole.child && task.isCompleted
                    ? () {
                  context.read<TaskBloc>().add(UncompleteTaskEvent(task: task));
                }
                    : null,
                onApprove: currentUserRole == UserRole.parent &&
                    task.isCompleted &&
                    !task.isApproved
                    ? () {
                  context.read<TaskBloc>().add(ApproveTaskEvent(task: task));
                }
                    : null,
              );
            },
          );
        } else if (state is TaskErrorState) {
          return Center(child: Text('Fehler: ${state.message}'));
        }
        return Center(child: Text(AppLocalizations.of(context)!.noTasksFound));
      },
    );
  }
}