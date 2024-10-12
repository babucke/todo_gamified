// lib/blocs/family/family_event.dart

import 'package:equatable/equatable.dart';

abstract class FamilyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class JoinFamily extends FamilyEvent {
  final String code;

  JoinFamily({required this.code});

  @override
  List<Object?> get props => [code];
}

class CreateFamily extends FamilyEvent {
  final String familyName;

  CreateFamily({required this.familyName});

  @override
  List<Object?> get props => [familyName];
}
