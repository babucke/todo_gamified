// lib/ui/screens/family/join_family_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/family/family_bloc.dart';
import '../../../blocs/family/family_event.dart';
import '../../../blocs/family/family_state.dart';

class JoinFamilyScreen extends StatefulWidget {
  @override
  _JoinFamilyScreenState createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends State<JoinFamilyScreen> {
  final TextEditingController _familyCodeController = TextEditingController();

  @override
  void dispose() {
    _familyCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einer Familie beitreten'),
      ),
      body: BlocListener<FamilyBloc, FamilyState>(
        listener: (context, state) {
          if (state is FamilyJoinSuccess) {
            Navigator.pushReplacementNamed(context, '/home');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erfolgreich einer Familie beigetreten!')),
            );
          } else if (state is FamilyJoinFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _familyCodeController,
                decoration: InputDecoration(
                  labelText: 'Familiencode eingeben',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Hintergrundfarbe
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: () {
                  final code = _familyCodeController.text.trim();
                  if (code.isNotEmpty) {
                    context.read<FamilyBloc>().add(JoinFamily(code: code));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bitte gib einen Familiencode ein.')),
                    );
                  }
                },
                child: Text(
                  'Beitreten',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
