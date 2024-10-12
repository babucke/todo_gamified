import 'package:uuid/uuid.dart';

class FamilyModel {
  final String familyId;
  final List<String> parentIds;
  final List<String> childIds;

  FamilyModel({
    required this.familyId,
    required this.parentIds,
    required this.childIds,
  });

  // Factory method to create a new Family with a UUID
  factory FamilyModel.create({
    required List<String> parentIds,
    required List<String> childIds,
  }) {
    var uuid = Uuid();
    return FamilyModel(
      familyId: uuid.v4(),
      parentIds: parentIds,
      childIds: childIds,
    );
  }

  factory FamilyModel.fromMap(Map<String, dynamic> data) {
    return FamilyModel(
      familyId: data['familyId'],
      parentIds: List<String>.from(data['parentIds']),
      childIds: List<String>.from(data['childIds']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'familyId': familyId,
      'parentIds': parentIds,
      'childIds': childIds,
    };
  }
}
