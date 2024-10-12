// lib/blocs/family/family_state.dart

import 'package:equatable/equatable.dart';

abstract class FamilyState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FamilyInitial extends FamilyState {}

class FamilyLoading extends FamilyState {}

class FamilyJoinSuccess extends FamilyState {}

class FamilyJoinFailure extends FamilyState {
  final String error;

  FamilyJoinFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class FamilyCreateSuccess extends FamilyState {}

class FamilyCreateFailure extends FamilyState {
  final String error;

  FamilyCreateFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
