import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final String assignedBy;
  final DateTime dueDate;
  final int xpValue;
  final bool isCompleted;
  final bool isApproved;
  final String? proofPhotoUrl;
  final bool isDaily;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedBy,
    required this.dueDate,
    required this.xpValue,
    required this.isCompleted,
    required this.isApproved,
    this.proofPhotoUrl,
    required this.isDaily,
  });

  factory TaskModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignedTo: data['assignedTo'] ?? '',
      assignedBy: data['assignedBy'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      xpValue: data['xpValue'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      isApproved: data['isApproved'] ?? false,
      proofPhotoUrl: data['proofPhotoUrl'],
      isDaily: data['isDaily'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'dueDate': dueDate,
      'xpValue': xpValue,
      'isCompleted': isCompleted,
      'isApproved': isApproved,
      'proofPhotoUrl': proofPhotoUrl,
      'isDaily': isDaily,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? assignedBy,
    DateTime? dueDate,
    int? xpValue,
    bool? isCompleted,
    bool? isApproved,
    String? proofPhotoUrl,
    bool? isDaily,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      dueDate: dueDate ?? this.dueDate,
      xpValue: xpValue ?? this.xpValue,
      isCompleted: isCompleted ?? this.isCompleted,
      isApproved: isApproved ?? this.isApproved,
      proofPhotoUrl: proofPhotoUrl ?? this.proofPhotoUrl,
      isDaily: isDaily ?? this.isDaily,
    );
  }
}