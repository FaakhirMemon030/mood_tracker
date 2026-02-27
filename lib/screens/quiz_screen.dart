import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/quiz_model.dart';
import '../services/firebase_service.dart';

class QuizScreen extends StatefulWidget {
  final String userId;
  const QuizScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FirebaseService _service = FirebaseService();

  void _handleQuizCompletion(QuizModel quiz, int selectedIndex) async {
    if (selectedIndex == quiz.correctOptionIndex) {
      await _service.completeQuiz(widget.userId, quiz.id, quiz.points);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('🎉 Correct!'),
            content: Text(quiz.funnyFeedback),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oops! Wrong answer. Try again! 😜')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Funny Quizzes')),
      body: StreamBuilder<List<QuizModel>>(
        stream: _service.getQuizzes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: SpinKitPulse(color: Colors.orange));
          final quizzes = snapshot.data!;

          if (quizzes.isEmpty) {
            return const Center(child: Text('No quizzes yet. Come back soon!'));
          }

          return ListView.builder(
            itemCount: quizzes.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.question,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      ...List.generate(quiz.options.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade50,
                              foregroundColor: Colors.blue.shade900,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: () => _handleQuizCompletion(quiz, i),
                            child: Text(quiz.options[i]),
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                      Text('💰 Points: ${quiz.points}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
