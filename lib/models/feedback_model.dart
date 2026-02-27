class FeedbackModel {
  final String id;
  final String uid;
  final String message;
  final DateTime timestamp;

  FeedbackModel({
    required this.id,
    required this.uid,
    required this.message,
    required this.timestamp,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map, String docId) {
    return FeedbackModel(
      id: docId,
      uid: map['uid'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null ? map['timestamp'].toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
