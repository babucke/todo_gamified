// lib/ui/screens/create_task_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../utils/enums.dart';
import '../../localization.dart';

class CreateTaskScreen extends StatefulWidget {
  final TaskModel? taskToEdit;

  const CreateTaskScreen({Key? key, this.taskToEdit}) : super(key: key);

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  late TextEditingController _xpValueController;
  String? _proofPhotoUrl;
  bool _isDaily = false;
  String? _selectedFamilyMemberId;
  List<UserModel> _familyMembers = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.taskToEdit?.description ?? '');
    _dueDate = widget.taskToEdit?.dueDate;
    _xpValueController = TextEditingController(text: widget.taskToEdit?.xpValue.toString() ?? '');
    _proofPhotoUrl = widget.taskToEdit?.proofPhotoUrl;
    _isDaily = widget.taskToEdit?.isDaily ?? false;
    _selectedFamilyMemberId = widget.taskToEdit?.assignedTo;
    _loadFamilyMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _xpValueController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      final familyId = userDoc.data()?['familyId'];
      if (familyId != null) {
        final familyMembersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('familyId', isEqualTo: familyId)
            .where('role', isEqualTo: UserRole.child.toString().split('.').last)
            .get();
        setState(() {
          _familyMembers = familyMembersSnapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList();

          if (_selectedFamilyMemberId == null ||
              !_familyMembers.any((member) => member.uid == _selectedFamilyMemberId)) {
            _selectedFamilyMemberId = _familyMembers.isNotEmpty ? _familyMembers.first.uid : null;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskToEdit == null ? localizations.createTask : localizations.editTask),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: localizations.title),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterTitle;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: localizations.description),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterDescription;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedFamilyMemberId,
                decoration: InputDecoration(labelText: localizations.assignTo),
                items: _familyMembers.map((member) {
                  return DropdownMenuItem(
                    value: member.uid,
                    child: Text(member.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFamilyMemberId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.selectFamilyMember;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ListTile(
                title: Text(_dueDate == null
                    ? localizations.selectDueDate
                    : '${_dueDate!.day}.${_dueDate!.month}.${_dueDate!.year}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _dueDate = picked;
                    });
                  }
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _xpValueController,
                decoration: InputDecoration(labelText: localizations.xpValue),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterXpValue;
                  }
                  if (int.tryParse(value) == null) {
                    return localizations.enterValidXpValue;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: _proofPhotoUrl,
                decoration: InputDecoration(labelText: localizations.proofPhotoUrl),
                onChanged: (value) {
                  _proofPhotoUrl = value;
                },
              ),
              SizedBox(height: 16.0),
              CheckboxListTile(
                title: Text(localizations.dailyTask),
                value: _isDaily,
                onChanged: (bool? value) {
                  setState(() {
                    _isDaily = value ?? false;
                  });
                },
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(widget.taskToEdit == null ? localizations.saveTask : localizations.updateTask),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTask() {
    final localizations = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate() && _dueDate != null && _selectedFamilyMemberId != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final taskId = widget.taskToEdit?.id ?? Uuid().v4();
        final task = TaskModel(
          id: taskId,
          title: _titleController.text,
          description: _descriptionController.text,
          assignedTo: _selectedFamilyMemberId!,
          assignedBy: currentUser.uid,
          dueDate: _dueDate!,
          xpValue: int.parse(_xpValueController.text),
          isCompleted: widget.taskToEdit?.isCompleted ?? false,
          isApproved: widget.taskToEdit?.isApproved ?? false,
          proofPhotoUrl: _proofPhotoUrl,
          isDaily: _isDaily,
        );

        if (widget.taskToEdit == null) {
          context.read<TaskBloc>().add(AddTaskEvent(task: task));
        } else {
          context.read<TaskBloc>().add(UpdateTaskEvent(task: task));
        }

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.userNotAuthenticated)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.fillAllFields)),
      );
    }
  }
}