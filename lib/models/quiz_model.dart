class QuizModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String funnyFeedback; // Message shown after answering correctly
  final int points;

  QuizModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.funnyFeedback = 'Hah! You got it right! 😂',
    this.points = 20,
  });

  factory QuizModel.fromMap(Map<String, dynamic> map, String docId) {
    return QuizModel(
      id: docId,
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
      funnyFeedback: map['funnyFeedback'] ?? 'Hah! You got it right! 😂',
      points: map['points'] ?? 20,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'funnyFeedback': funnyFeedback,
      'points': points,
    };
  }
}
