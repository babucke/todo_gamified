import 'package:uuid/uuid.dart';

class RewardModel {
  final String rewardId;
  final String title;
  final String description;
  final int requiredLevel;

  RewardModel({
    required this.rewardId,
    required this.title,
    required this.description,
    required this.requiredLevel,
  });

  // Methode zum Erstellen einer neuen Belohnung mit UUID
  factory RewardModel.create({
    required String title,
    required String description,
    required int requiredLevel,
  }) {
    var uuid = Uuid();
    return RewardModel(
      rewardId: uuid.v4(),
      title: title,
      description: description,
      requiredLevel: requiredLevel,
    );
  }

  factory RewardModel.fromMap(Map<String, dynamic> data) {
    return RewardModel(
      rewardId: data['rewardId'],
      title: data['title'],
      description: data['description'],
      requiredLevel: data['requiredLevel'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rewardId': rewardId,
      'title': title,
      'description': description,
      'requiredLevel': requiredLevel,
    };
  }
}
