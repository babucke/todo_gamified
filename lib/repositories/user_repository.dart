// lib/repositories/user_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/enums.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserRole> getUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String roleString = userData['role'] as String;

      switch (roleString) {
        case 'parent':
          return UserRole.parent;
        case 'child':
          return UserRole.child;
        default:
          return UserRole.unknown;
      }
    } catch (e) {
      print('Error getting user role: $e');
      return UserRole.unknown;
    }
  }
}