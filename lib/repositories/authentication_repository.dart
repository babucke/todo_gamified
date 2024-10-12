// lib/repositories/authentication_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../utils/enums.dart';

class AuthenticationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Registrierung mit E-Mail und Passwort
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        // Sende eine Verifizierungs-E-Mail
        await firebaseUser.sendEmailVerification();

        // Erstelle einen neuen UserModel
        UserModel user = UserModel(
          uid: firebaseUser.uid,
          name: name,
          role: role,
          familyId: '', // Wird später zugewiesen
        );

        // Speichere den Benutzer in Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).set(user.toMap());

        return user;
      } else {
        throw Exception('Benutzer konnte nicht erstellt werden.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Anmeldung mit E-Mail und Passwort
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        if (!firebaseUser.emailVerified) {
          throw Exception('Bitte bestätige deine E-Mail-Adresse.');
        }

        // Hole den Benutzer aus Firestore
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (userDoc.exists) {
          UserModel user =
          UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          return user;
        } else {
          throw Exception('Benutzer nicht gefunden.');
        }
      } else {
        throw Exception('Anmeldung fehlgeschlagen.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Google Sign-In
  Future<UserModel> signInWithGoogle() async {
    try {
      // Schritt 1: Benutzer wählt Google-Konto aus
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Anmeldung abgebrochen');
      }

      // Schritt 2: Hole die Authentifizierungsdetails
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Schritt 3: Erstelle ein neues Credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Schritt 4: Melde den Benutzer bei Firebase an
      UserCredential result = await _auth.signInWithCredential(credential);
      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        // Überprüfe, ob der Benutzer bereits in Firestore existiert
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (!userDoc.exists) {
          // Benutzer ist neu, Rolle ist noch nicht festgelegt
          UserModel user = UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Benutzer',
            role: UserRole.unknown, // Setze auf 'unknown', um eine Rolle auswählen zu müssen
            familyId: '', // Wird später zugewiesen
          );

          // Speichere den Benutzer mit unbekannter Rolle in Firestore
          await _firestore.collection('users').doc(firebaseUser.uid).set(user.toMap());

          return user;
        } else {
          // Benutzer existiert bereits, hole die Daten
          UserModel user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          return user;
        }
      } else {
        throw Exception('Anmeldung fehlgeschlagen.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Aktualisiere die Rolle des Benutzers
  Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': role.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren der Rolle: ${e.toString()}');
    }
  }

  // Methode zum Abrufen des aktuellen Firebase-Benutzers
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Methode zum Abrufen des Benutzer-Dokuments aus Firestore
  Future<DocumentSnapshot> getUserDoc(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  // Abmelden
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
