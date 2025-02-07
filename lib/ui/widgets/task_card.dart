import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/task_model.dart';
import '../../utils/enums.dart';
import '../../localization.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import '../screens/photo_view_screen.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onComplete;
  final VoidCallback? onApprove;
  final VoidCallback? onUncomplete;
  final UserRole userRole;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onDelete,
    required this.onEdit,
    this.onComplete,
    this.onUncomplete, // Neuer Parameter
    this.onApprove,
    required this.userRole,
  }) : super(key: key);

  Future<void> updateTaskWithPhotoUrl(String taskId, String photoUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .update({'proofPhotoUrl': photoUrl});
      print('Task document updated with photo URL successfully');
    } catch (e) {
      print('Error updating task document: $e');
      throw e;
    }
  }

  Future<void> _uploadProofPhoto(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      File imageFile = File(image.path);
      try {
        final storageRef = FirebaseStorage.instance.ref();
        final taskProofRef = storageRef.child('task_proofs/${task.id}.jpg');

        await taskProofRef.putFile(imageFile);
        String downloadURL = await taskProofRef.getDownloadURL();

        await updateTaskWithPhotoUrl(task.id, downloadURL);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.photoUploadedSuccessfully)),
        );
      } catch (e) {
        print('Error uploading photo: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorUploadingPhoto)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final dueDate = task.dueDate;
    final isOverdue = dueDate.isBefore(DateTime.now()) && !task.isCompleted;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: userRole == UserRole.child ?
              (task.isCompleted ? onUncomplete : onComplete) : null,
              child: Icon(
                task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: task.isCompleted ? Colors.green : (isOverdue ? Colors.red : Colors.grey),
              ),
            ),
            title: Text(task.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description),
                Text('${localizations.dueDate}: ${dueDate.day}.${dueDate.month}.${dueDate.year}'),
                if (task.isDaily) Text(localizations.dailyTask),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(task.assignedTo).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(localizations.loading);
                    }
                    if (snapshot.hasError) {
                      return Text(localizations.error);
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      final userData = snapshot.data!.data() as Map<String, dynamic>?;
                      final assignedToName = userData?['name'] ?? localizations.unknownUser;
                      return Text('${localizations.assignedTo}: $assignedToName');
                    }
                    return Text(localizations.unknownUser);
                  },
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (userRole == UserRole.parent)
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: onEdit,
                    tooltip: localizations.editTask,
                  ),
                if (userRole == UserRole.parent)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: localizations.deleteTask,
                  ),
                if (userRole == UserRole.child && !task.isCompleted)
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: onComplete,
                    tooltip: localizations.completeTask,
                  ),
                if (userRole == UserRole.child && task.isCompleted && task.proofPhotoUrl == null)
                  IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.orange),
                    onPressed: () => _uploadProofPhoto(context),
                    tooltip: localizations.addProofPhoto,
                  ),
                if (userRole == UserRole.parent && task.isCompleted && !task.isApproved)
                  IconButton(
                    icon: Icon(Icons.approval, color: Colors.orange),
                    onPressed: onApprove,
                    tooltip: localizations.approveTask,
                  ),
              ],
            ),
          ),
          if (task.proofPhotoUrl != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoViewScreen(photoUrl: task.proofPhotoUrl!),
                    ),
                  );
                },
                child: Text(localizations.viewProofPhoto),
              ),
            ),
          if (userRole == UserRole.child && task.isCompleted && task.proofPhotoUrl != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => _uploadProofPhoto(context),
                child: Text(localizations.updateProofPhoto),
              ),
            ),
        ],
      ),
    );
  }
}