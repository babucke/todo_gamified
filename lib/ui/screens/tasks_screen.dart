// lib/screens/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/task/task_state.dart';
import '../../models/task_model.dart';
import '../../localization.dart';
import '../widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      currentUserId = currentUser.uid;
      // Lade die Aufgaben für den aktuellen Benutzer
      context.read<TaskBloc>().add(LoadTasksEvent(userId: currentUserId));
      print('LoadTasksEvent dispatched for userId: $currentUserId');
    } else {
      print('Kein authentifizierter Benutzer gefunden.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.tasks),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoadingState) {
            print('TaskBloc: TaskLoadingState');
            return Center(child: CircularProgressIndicator());
          } else if (state is TaskErrorState) {
            print('TaskBloc: TaskErrorState - ${state.message}');
            return Center(child: Text('${localizations.error}: ${state.message}'));
          } else if (state is TaskLoadedState) {
            print('TaskBloc: TaskLoadedState - ${state.tasks.length} Aufgaben gefunden.');
            final tasks = state.tasks;
            if (tasks.isEmpty) {
              return Center(child: Text(localizations.noTasksFound));
            }
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  onDelete: () {
                    // Event zum Löschen der Aufgabe mit der aktuellen userId
                    context.read<TaskBloc>().add(DeleteTaskEvent(taskId: task.id, userId: currentUserId));
                  },
                );
              },
            );
          } else {
            print('TaskBloc: Unbekannter Zustand');
            return Center(child: Text(localizations.noTasksFound));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigiere zum Task-Erstellungsbildschirm
          Navigator.pushNamed(context, '/createTask');
        },
        child: Icon(Icons.add),
        tooltip: localizations.addTask,
      ),
    );
  }
}
