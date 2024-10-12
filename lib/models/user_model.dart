// lib/models/user_model.dart

import 'package:equatable/equatable.dart';
import '../utils/enums.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final UserRole role;
  final String familyId;

  UserModel({
    required this.uid,
    required this.name,
    required this.role,
    required this.familyId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Debugging: Drucke den empfangenen Map
    print('UserModel.fromMap: $map');

    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      role: UserRole.values.firstWhere(
            (e) => e.toString() == 'UserRole.${map['role']}',
        orElse: () => UserRole.unknown, // Fallback-Wert
      ),
      familyId: map['familyId'] as String? ?? '', // Fallback auf leeren String
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'role': role.toString().split('.').last,
      'familyId': familyId,
    };
  }

  @override
  List<Object?> get props => [uid, name, role, familyId];
}
