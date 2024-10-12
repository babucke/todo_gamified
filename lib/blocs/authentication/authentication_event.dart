// lib/blocs/authentication/authentication_event.dart

import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';
import '../../utils/enums.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpRequested extends AuthenticationEvent {
  final String email;
  final String password;
  final String name;
  final UserRole role;

  SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}

class SignInRequested extends AuthenticationEvent {
  final String email;
  final String password;

  SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class GoogleSignInRequested extends AuthenticationEvent {}

class RoleSelected extends AuthenticationEvent {
  final UserRole role;

  RoleSelected({required this.role});

  @override
  List<Object?> get props => [role];
}

class SignOutRequested extends AuthenticationEvent {}

// Neues Event hinzufügen
class SignInAuthenticated extends AuthenticationEvent {
  final UserModel user;

  SignInAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}
