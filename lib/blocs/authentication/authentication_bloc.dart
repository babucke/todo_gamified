// lib/blocs/authentication/authentication_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/enums.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';
import '../../repositories/authentication_repository.dart';
import '../../models/user_model.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository authenticationRepository;

  AuthenticationBloc({required this.authenticationRepository}) : super(AuthenticationInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<RoleSelected>(_onRoleSelected);
    on<SignInAuthenticated>(_onSignInAuthenticated);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      final user = await authenticationRepository.signUp(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
      );
      emit(AuthenticationNeedsVerification(user: user));
    } catch (e) {
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      final user = await authenticationRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthenticationAuthenticated(user: user));
    } catch (e) {
      if (e.toString().contains('Bitte bestätige deine E-Mail-Adresse')) {
        final firebaseUser = authenticationRepository.getCurrentUser();
        if (firebaseUser != null) {
          final userDoc = await authenticationRepository.getUserDoc(firebaseUser.uid);
          final user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          emit(AuthenticationNeedsVerification(user: user));
        } else {
          emit(AuthenticationError(message: 'Benutzer nicht angemeldet.'));
        }
      } else {
        emit(AuthenticationError(message: e.toString()));
      }
    }
  }

  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    print('GoogleSignInRequested Event ausgelöst');
    try {
      final user = await authenticationRepository.signInWithGoogle();
      print('Benutzer nach Google Sign-In: ${user.toMap()}');

      if (user.role == UserRole.unknown || user.role == null) {
        print('Benutzer muss eine Rolle auswählen');
        emit(AuthenticationNeedsRole(user: user));
      } else {
        print('Benutzer ist authentifiziert');
        emit(AuthenticationAuthenticated(user: user));
      }
    } catch (e) {
      print('Fehler beim Google Sign-In: ${e.toString()}');
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onRoleSelected(RoleSelected event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    print('RoleSelected Event ausgelöst mit Rolle: ${event.role}');
    try {
      final firebaseUser = authenticationRepository.getCurrentUser();

      if (firebaseUser != null) {
        // Aktualisiere die Rolle in Firestore
        await authenticationRepository.updateUserRole(firebaseUser.uid, event.role);
        print('Rolle in Firestore aktualisiert');

        // Hole das aktualisierte Benutzerprofil
        final userDoc = await authenticationRepository.getUserDoc(firebaseUser.uid);
        final user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        print('Aktualisiertes Benutzerprofil: ${user.toMap()}');

        emit(AuthenticationAuthenticated(user: user));
        print('AuthenticationAuthenticated Zustand emittiert');
      } else {
        print('Benutzer ist nicht angemeldet');
        emit(AuthenticationError(message: 'Benutzer nicht angemeldet.'));
      }
    } catch (e) {
      print('Fehler beim Aktualisieren der Rolle: ${e.toString()}');
      emit(AuthenticationError(message: e.toString()));
    }
  }

  Future<void> _onSignInAuthenticated(SignInAuthenticated event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationAuthenticated(user: event.user));
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    await authenticationRepository.signOut();
    emit(AuthenticationInitial());
  }
}
