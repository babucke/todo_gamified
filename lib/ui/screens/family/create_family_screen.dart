// lib/ui/screens/family/create_family_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_gamified/blocs/family/family_event.dart';
import '../../../blocs/family/family_bloc.dart';
import '../../../blocs/family/family_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateFamilyScreen extends StatefulWidget {
  @override
  _CreateFamilyScreenState createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends State<CreateFamilyScreen> {
  final TextEditingController _familyNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Familie gründen'),
      ),
      body: BlocListener<FamilyBloc, FamilyState>(
        listener: (context, state) async {
          if (state is FamilyCreateSuccess) {
            // Suche die erstellte Familie basierend auf createdBy
            final familyQuery = await FirebaseFirestore.instance
                .collection('families')
                .where('createdBy', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .get();

            String familyCode = '';
            if (familyQuery.docs.isNotEmpty) {
              familyCode = familyQuery.docs.first['familyCode'];
            }

            // Zeige den Familiencode im Dialog an
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Familie erfolgreich gegründet!'),
                content: Text('Dein Familiencode: $familyCode'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Schließt das Dialogfenster
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          } else if (state is FamilyCreateFailure) {
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
                controller: _familyNameController,
                decoration: InputDecoration(
                  labelText: 'Familienname eingeben',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Aktualisiert von 'primary' zu 'backgroundColor'
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: () {
                  final name = _familyNameController.text.trim();
                  if (name.isNotEmpty) {
                    context.read<FamilyBloc>().add(CreateFamily(familyName: name));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bitte gib einen Familiennamen ein.')),
                    );
                  }
                },
                child: Text(
                  'Familie gründen',
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
