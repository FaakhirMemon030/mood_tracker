import 'package:flutter/material.dart';
import '../../models/challenge_model.dart';
import '../../services/firebase_service.dart';

class FunnyChallenges extends StatelessWidget {
  final List<ChallengeModel> challenges;
  final List<String> completedIds;
  final Function(String) onComplete;

  const FunnyChallenges({
    Key? key,
    required this.challenges,
    required this.completedIds,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return const Center(child: Text('No challenges available right now!'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        final isCompleted = completedIds.contains(challenge.id);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(
              isCompleted ? Icons.check_circle : Icons.emoji_emotions,
              color: isCompleted ? Colors.green : Colors.orange,
              size: 40,
            ),
            title: Text(
              challenge.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(challenge.description),
            trailing: isCompleted
                ? const Text('Done!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                : ElevatedButton(
                    onPressed: () => onComplete(challenge.id),
                    child: const Text('Complete'),
                  ),
          ),
        );
      },
    );
  }
}
