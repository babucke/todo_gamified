// lib/models/task_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final DateTime dueDate;
  final int xpValue;
  final bool isCompleted;
  final String? proofPhotoUrl;
  final bool isDaily; // Neues Feld für tägliche Aufgaben

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.dueDate,
    required this.xpValue,
    required this.isCompleted,
    this.proofPhotoUrl,
    required this.isDaily, // Neuer Parameter
  });

  factory TaskModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignedTo: data['assignedTo'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      xpValue: data['xpValue'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      proofPhotoUrl: data['proofPhotoUrl'],
      isDaily: data['isDaily'] ?? false, // Neues Feld
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'dueDate': dueDate,
      'xpValue': xpValue,
      'isCompleted': isCompleted,
      'proofPhotoUrl': proofPhotoUrl,
      'isDaily': isDaily, // Neues Feld
    };
  }
}