// lib/repositories/task_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../utils/enums.dart';

class TaskRepository {
  final FirebaseFirestore firestore;

  TaskRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  // Alle Aufgaben eines bestimmten Benutzers abrufen
  Future<List<TaskModel>> getTasks(String userId) async {
    try {
      // Hole zuerst die Benutzerrolle
      DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();
      String userRole = userDoc['role'];

      QuerySnapshot snapshot;
      if (userRole == UserRole.parent.toString().split('.').last) {
        // Für Eltern: Hole alle Aufgaben, die sie erstellt haben
        snapshot = await firestore
            .collection('tasks')
            .where('assignedBy', isEqualTo: userId)
            .get();
      } else {
        // Für Kinder: Hole alle Aufgaben, die ihnen zugewiesen wurden
        snapshot = await firestore
            .collection('tasks')
            .where('assignedTo', isEqualTo: userId)
            .get();
      }

      print('Gefundene Aufgaben: ${snapshot.docs.length}'); // Debug-Ausgabe

      return snapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Fehler beim Abrufen der Aufgaben: $e'); // Debug-Ausgabe
      throw Exception('Fehler beim Abrufen der Aufgaben: $e');
    }
  }

  // Eine neue Aufgabe hinzufügen
  Future<void> addTask(TaskModel task) async {
    try {
      await firestore.collection('tasks').doc(task.id).set(task.toMap());
    } catch (e) {
      throw Exception('Fehler beim Hinzufügen der Aufgabe: $e');
    }
  }

  // Eine Aufgabe aktualisieren
  Future<void> updateTask(TaskModel task) async {
    try {
      await firestore.collection('tasks').doc(task.id).update(task.toMap());
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren der Aufgabe: $e');
    }
  }

  // Eine Aufgabe löschen
  Future<void> deleteTask(String taskId) async {
    try {
      await firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Fehler beim Löschen der Aufgabe: $e');
    }
  }
}