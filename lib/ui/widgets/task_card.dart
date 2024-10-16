// lib/ui/widgets/task_card.dart

import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../localization.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onDelete;

  const TaskCard({Key? key, required this.task, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final dueDate = task.dueDate;
    final isOverdue = dueDate.isBefore(DateTime.now()) && !task.isCompleted;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Icon(
          task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
          color: task.isCompleted ? Colors.green : (isOverdue ? Colors.red : Colors.grey),
        ),
        title: Row(
          children: [
            Expanded(child: Text(task.title)),
            if (task.isDaily)
              Icon(Icons.repeat, color: Colors.blue, size: 20),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            SizedBox(height: 4.0),
            Text(
              '${localizations.dueDate}: ${dueDate.day}.${dueDate.month}.${dueDate.year}',
              style: TextStyle(
                color: isOverdue ? Colors.red : Colors.black,
              ),
            ),
            if (task.isDaily)
              Text(
                localizations.dailyTask,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
          tooltip: localizations.deleteTask,
        ),
        onTap: () {
          // Optional: Navigiere zur Detailansicht oder Bearbeitungsseite
        },
      ),
    );
  }
}