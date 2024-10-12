// lib/blocs/authentication/authentication_state.dart

import 'package:equatable/equatable.dart';

import '../../models/user_model.dart';

abstract class AuthenticationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final UserModel user;

  AuthenticationAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthenticationNeedsVerification extends AuthenticationState {
  final UserModel user;

  AuthenticationNeedsVerification({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthenticationNeedsRole extends AuthenticationState {
  final UserModel user;

  AuthenticationNeedsRole({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthenticationError extends AuthenticationState {
  final String message;

  AuthenticationError({required this.message});

  @override
  List<Object?> get props => [message];
}
