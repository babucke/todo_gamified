import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class TaskModel {
  final String taskId;
  final String title;
  final String description;
  final String assignedTo; // UID des Kindes
  final DateTime dueDate;
  final bool isCompleted;
  final String? proofPhotoUrl;
  final int xpValue;

  TaskModel({
    required this.taskId,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.dueDate,
    this.isCompleted = false,
    this.proofPhotoUrl,
    required this.xpValue,
  });

  // Methode zum Erstellen einer neuen Aufgabe mit UUID
  factory TaskModel.create({
    required String title,
    required String description,
    required String assignedTo,
    required DateTime dueDate,
    required int xpValue,
  }) {
    var uuid = Uuid();
    return TaskModel(
      taskId: uuid.v4(),
      title: title,
      description: description,
      assignedTo: assignedTo,
      dueDate: dueDate,
      xpValue: xpValue,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> data) {
    return TaskModel(
      taskId: data['taskId'],
      title: data['title'],
      description: data['description'],
      assignedTo: data['assignedTo'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      proofPhotoUrl: data['proofPhotoUrl'],
      xpValue: data['xpValue'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'dueDate': dueDate,
      'isCompleted': isCompleted,
      'proofPhotoUrl': proofPhotoUrl,
      'xpValue': xpValue,
    };
  }
}
