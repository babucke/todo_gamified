// lib/ui/screens/create_task_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../models/task_model.dart';
import '../../localization.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({Key? key}) : super(key: key);

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  final _xpValueController = TextEditingController();
  String? _proofPhotoUrl;
  bool _isDaily = false; // Neuer State für tägliche Aufgaben

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.createTask),
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
                decoration: InputDecoration(labelText: localizations.proofPhotoUrl),
                onChanged: (value) {
                  _proofPhotoUrl = value;
                },
              ),
              SizedBox(height: 16.0),
              // Neues Feld für tägliche Aufgaben
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
                onPressed: () {
                  if (_formKey.currentState!.validate() && _dueDate != null) {
                    final taskId = Uuid().v4();
                    final task = TaskModel(
                      id: taskId,
                      title: _titleController.text,
                      description: _descriptionController.text,
                      assignedTo: currentUser!.uid,
                      dueDate: _dueDate!,
                      xpValue: int.parse(_xpValueController.text),
                      isCompleted: false,
                      proofPhotoUrl: _proofPhotoUrl,
                      isDaily: _isDaily, // Neues Feld
                    );
                    context.read<TaskBloc>().add(AddTaskEvent(task: task));
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.selectDueDate)),
                    );
                  }
                },
                child: Text(localizations.saveTask),
              ),
            ],
          ),
        ),
      ),
    );
  }
}