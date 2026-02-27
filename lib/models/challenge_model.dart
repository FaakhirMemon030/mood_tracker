class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final int points;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    this.points = 10,
  });

  factory ChallengeModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChallengeModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      points: map['points'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'points': points,
    };
  }
}
