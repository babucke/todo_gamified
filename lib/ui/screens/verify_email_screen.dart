// lib/ui/screens/verify_email_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/authentication/authentication_bloc.dart';
import '../../blocs/authentication/authentication_event.dart';
import '../../blocs/authentication/authentication_state.dart';
import '../../models/user_model.dart';
import '../../utils/enums.dart';

class VerifyEmailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Mail verifizieren'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationAuthenticated) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (state is AuthenticationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Eine Verifizierungs-E-Mail wurde an deine Adresse gesendet.\n'
                    'Bitte überprüfe dein E-Mail-Postfach und bestätige deine E-Mail.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  User? firebaseUser = FirebaseAuth.instance.currentUser;

                  if (firebaseUser != null) {
                    try {
                      // Benutzerdaten aktualisieren
                      await firebaseUser.reload();
                      User? updatedUser = FirebaseAuth.instance.currentUser;

                      if (updatedUser != null && updatedUser.emailVerified) {
                        // Hole das aktualisierte Benutzerprofil aus Firestore
                        DocumentSnapshot userDoc = await context
                            .read<AuthenticationBloc>()
                            .authenticationRepository
                            .getUserDoc(updatedUser.uid);

                        UserModel user =
                        UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

                        // Prüfe, ob die Rolle festgelegt wurde
                        if (user.role == UserRole.parent || user.role == UserRole.child) {
                          // Rolle ist festgelegt, sende ein Event zur Authentifizierung
                          context.read<AuthenticationBloc>().add(SignInAuthenticated(user: user));
                        } else {
                          // Rolle ist noch nicht festgelegt, sende ein Event zur Rollenwahl
                          context.read<AuthenticationBloc>().add(RoleSelected(role: UserRole.parent)); // Beispiel: Setze auf 'parent'
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('E-Mail wurde noch nicht verifiziert.')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fehler: ${e.toString()}')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Benutzer nicht angemeldet.')),
                    );
                  }
                },
                child: Text('Überprüfen'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  User? firebaseUser = FirebaseAuth.instance.currentUser;

                  if (firebaseUser != null && !firebaseUser.emailVerified) {
                    try {
                      await firebaseUser.sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Verifizierungs-E-Mail wurde erneut gesendet.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fehler: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: Text('Verifizierungs-E-Mail erneut senden'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthenticationBloc>().add(SignOutRequested());
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text('Abmelden'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
