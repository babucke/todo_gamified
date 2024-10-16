// lib/repositories/task_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore firestore;

  TaskRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  // Alle Aufgaben eines bestimmten Benutzers abrufen
  Future<List<TaskModel>> getTasks(String userId) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('tasks')
          .where('assignedTo', isEqualTo: userId)
          .orderBy('dueDate')
          .orderBy('__name__') // Muss mit dem erstellten Index übereinstimmen
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
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
