// lib/repositories/family_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class FamilyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Methode zum Beitreten einer Familie über den Code
  Future<void> joinFamily(String code) async {
    // Suche die familyId anhand des familyCode in der familyCodes-Sammlung
    final familyCodeQuery = await _firestore
        .collection('familyCodes')
        .where('familyCode', isEqualTo: code)
        .limit(1)
        .get();

    if (familyCodeQuery.docs.isEmpty) {
      throw Exception('Ungültiger Familiencode.');
    }

    final familyCodeDoc = familyCodeQuery.docs.first;
    final familyId = familyCodeDoc['familyId'];

    // Überprüfen, ob der Benutzer bereits einer Familie angehört
    final userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    if (userDoc.exists && (userDoc.data()!['familyId'] != null && userDoc.data()!['familyId'] != '')) {
      throw Exception('Du bist bereits einer Familie beigetreten.');
    }

    // Aktualisiere die familyId im Benutzer-Dokument
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'familyId': familyId,
    });

    // Füge den Benutzer zur Familienmitgliederliste hinzu
    await _firestore.collection('families').doc(familyId).update({
      'members': FieldValue.arrayUnion([_auth.currentUser!.uid]),
    });
  }

  // Methode zum Erstellen einer neuen Familie
  Future<void> createFamily(String familyName) async {
    // Überprüfen, ob der Benutzer bereits einer Familie angehört
    final userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    if (userDoc.exists && (userDoc.data()!['familyId'] != null && userDoc.data()!['familyId'] != '')) {
      throw Exception('Du bist bereits einer Familie beigetreten.');
    }

    // Generiere einen eindeutigen Familiencode
    String familyCode = _generateFamilyCode() as String;

    // Erstelle eine neue Familie
    final familyRef = await _firestore.collection('families').add({
      'familyName': familyName,
      'familyCode': familyCode,
      'createdBy': _auth.currentUser!.uid, // Wichtig für die Sicherheitsregeln
      'members': [_auth.currentUser!.uid],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Erstelle einen Eintrag in der familyCodes-Sammlung
    await _firestore.collection('familyCodes').add({
      'familyCode': familyCode,
      'familyId': familyRef.id,
      'createdBy': _auth.currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Aktualisiere die familyId im Benutzer-Dokument
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'familyId': familyRef.id,
    });
  }

  // Hilfsmethode zur Generierung eines zufälligen Familiencodes
  Future<String> _generateFamilyCode() async {
    const length = 6;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random.secure();
    String code;
    do {
      code = String.fromCharCodes(Iterable.generate(
          length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
    } while (await _isFamilyCodeExists(code));
    return code;
  }

  // Methode zur Überprüfung, ob ein Familiencode bereits existiert
  Future<bool> _isFamilyCodeExists(String code) async {
    final query = await _firestore
        .collection('familyCodes')
        .where('familyCode', isEqualTo: code)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }
}
