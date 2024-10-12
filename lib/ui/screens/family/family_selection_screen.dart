// lib/ui/screens/family_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/family/family_bloc.dart';
import '../../../blocs/family/family_event.dart';
import '../../../blocs/family/family_state.dart';

class FamilySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Familie auswählen'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/joinFamily');
                },
                child: Text('Einer Familie beitreten'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/createFamily');
                },
                child: Text('Familie gründen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
