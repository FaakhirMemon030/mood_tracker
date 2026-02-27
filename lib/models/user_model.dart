class UserModel {
  final String uid;
  final String email;
  final String name;
  final String mood;
  final List<String> completedChallenges;
  final bool isBanned;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.mood = 'Neutral',
    this.completedChallenges = const [],
    this.isBanned = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      mood: map['mood'] ?? 'Neutral',
      completedChallenges: List<String>.from(map['completedChallenges'] ?? []),
      isBanned: map['isBanned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'mood': mood,
      'completedChallenges': completedChallenges,
      'isBanned': isBanned,
    };
  }
}
