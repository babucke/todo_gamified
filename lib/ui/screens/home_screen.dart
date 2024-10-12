// lib/ui/screens/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../localization.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchFamilyMembers() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Benutzer ist nicht authentifiziert.');
    }

    // Holen Sie sich das Benutzer-Dokument, um die familyId zu erhalten
    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (!userDoc.exists) {
      throw Exception('Benutzer-Dokument existiert nicht.');
    }

    final familyId = userDoc.data()!['familyId'];
    if (familyId == null || familyId.isEmpty) {
      throw Exception('Benutzer gehört keiner Familie an.');
    }

    // Holen Sie sich das Familien-Dokument, um die Mitglieder-UIDs zu erhalten
    final familyDoc = await _firestore.collection('families').doc(familyId).get();
    if (!familyDoc.exists) {
      throw Exception('Familien-Dokument existiert nicht.');
    }

    final List<dynamic> memberUids = familyDoc.data()!['members'];
    if (memberUids.isEmpty) {
      return [];
    }

    // Holen Sie sich die Benutzerdaten für jede UID
    final members = await Future.wait(memberUids.map((uid) async {
      final memberDoc = await _firestore.collection('users').doc(uid).get();
      if (memberDoc.exists) {
        return memberDoc.data()!;
      } else {
        return {
          'uid': uid,
          'name': 'Unbekanntes Mitglied',
          'role': 'unknown',
        };
      }
    }));

    return members.cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    // Zugriff auf die lokalisierten Strings
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Familienmitglieder'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFamilyMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Ladeindikator anzeigen
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Fehlermeldung anzeigen
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Nachricht anzeigen, wenn keine Mitglieder gefunden wurden
            return Center(child: Text('Keine Mitglieder gefunden.'));
          } else {
            // Mitgliederliste anzeigen
            final members = snapshot.data!;
            return ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                String role = member['role'] ?? 'unknown';

                // Übersetzen der Rolle
                String translatedRole;
                switch (role.toLowerCase()) {
                  case 'parent':
                    translatedRole = localizations.roleParent;
                    break;
                  case 'child':
                    translatedRole = localizations.roleChild;
                    break;
                  default:
                    translatedRole = localizations.unknownRole;
                }

                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(member['name'] ?? 'Unbekanntes Mitglied'),
                  subtitle: Text('Rolle: $translatedRole'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
