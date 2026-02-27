import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/feedback_model.dart';
import '../models/challenge_model.dart';
import '../models/quiz_model.dart';
import 'login_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _service = FirebaseService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  // --- Users Tab ---
  Widget _buildUsersTab() {
    return StreamBuilder<List<UserModel>>(
      stream: _service.getAllUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: SpinKitWave(color: Theme.of(context).primaryColor, size: 30.0));
        final users = snapshot.data!;
        
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${user.email} | Mood: ${user.mood}'),
                trailing: _buildBanButton(user),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBanButton(UserModel user) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: user.isBanned ? Colors.green : Colors.red,
      ),
      onPressed: () async {
        await _service.toggleBanStatus(user.uid, user.isBanned);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(user.isBanned ? 'User Unbanned' : 'User Banned')),
          );
        }
      },
      child: Text(user.isBanned ? 'Unban' : 'Ban', style: const TextStyle(color: Colors.white)),
    );
  }

  // --- Feedback Tab ---
  Widget _buildFeedbackTab() {
    return StreamBuilder<List<FeedbackModel>>(
      stream: _service.getAllFeedback(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: SpinKitWave(color: Theme.of(context).primaryColor, size: 30.0));
        final feedbacks = snapshot.data!;
        
        return ListView.builder(
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final fb = feedbacks[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: const Icon(Icons.feedback, color: Colors.amber),
                title: Text(fb.message),
                subtitle: Text('User ID: ${fb.uid}\nDate: ${fb.timestamp.toLocal()}'),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  // --- Challenges Tab ---
  Widget _buildChallengesTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChallengeDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<ChallengeModel>>(
        stream: _service.getChallenges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: SpinKitWave(color: Theme.of(context).primaryColor, size: 30.0));
          final challenges = snapshot.data!;
          
          return ListView.builder(
            itemCount: challenges.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.only(bottom: 15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.purple.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    title: Text(
                      challenge.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(challenge.description),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '💰 ${challenge.points} Points',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showChallengeDialog(existing: challenge),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                             // Simple confirmation logic can be added here
                             await _service.deleteChallenge(challenge.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- Quizzes Tab ---
  Widget _buildQuizzesTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuizDialog(),
        child: const Icon(Icons.add_comment),
      ),
      body: StreamBuilder<List<QuizModel>>(
        stream: _service.getQuizzes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: SpinKitWave(color: Theme.of(context).primaryColor, size: 30.0));
          final quizzes = snapshot.data!;
          
          return ListView.builder(
            itemCount: quizzes.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.only(bottom: 15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    title: Text(
                      quiz.question,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         const SizedBox(height: 5),
                         Text('Options: ${quiz.options.join(", ")}', style: const TextStyle(fontSize: 12)),
                         Text('Correct: ${quiz.options[quiz.correctOptionIndex]}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showQuizDialog(existing: quiz),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                             await _service.deleteQuiz(quiz.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showChallengeDialog({ChallengeModel? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final pointsCtrl = TextEditingController(text: (existing?.points ?? 10).toString());

    final List<Map<String, String>> funnyPresets = [
      {'title': '🦆 Duck Walk', 'desc': 'Walk like a duck across the room for 1 minute!'},
      {'title': '🦖 T-Rex Mode', 'desc': 'Keep your elbows tucked into your ribs and act like a T-Rex for 2 minutes!'},
      {'title': '🤫 Silent Treatment', 'desc': 'Don\'t say a single word (even through text) for the next 15 minutes.'},
      {'title': '🐒 Monkey See', 'desc': 'Imitate the movements/sounds of the last person you saw for 2 minutes.'},
      {'title': '🧱 Wall Talk', 'desc': 'Have a 1-minute serious conversation with a wall about its favorite color.'},
      {'title': '🧘 Slow Motion', 'desc': 'Do everything in SUPER SLOW MOTION for the next 5 minutes.'},
      {'title': '🧦 Sock Puppet', 'desc': 'Put a sock on your hand and introduce it to everyone as your "Manager".'},
      {'title': '🥨 Human Pretzel', 'desc': 'Try to touch your nose with your toe! (Don\'t break anything!)'},
      {'title': '🎤 Bathroom Concert', 'desc': 'Sing "Baby Shark" loudly like you\'re at a rock concert.'},
      {'title': '🤣 Dad Joke Master', 'desc': 'Call a friend and tell them the worst dad joke you know.'},
      {'title': '🦒 Giraffe Challenge', 'desc': 'Walk on your tiptoes with your neck stretched as high as possible for 1 min.'},
      {'title': '🍋 Sour Face', 'desc': 'Eat a slice of lemon without making ANY faces. Record it!'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(existing == null ? 'Add Challenge' : 'Edit Challenge'),
                  if (existing == null)
                    PopupMenuButton<Map<String, String>>(
                      icon: const Icon(Icons.auto_awesome, color: Colors.purple),
                      tooltip: 'Tarakhta Pharkta Presets',
                      onSelected: (preset) {
                        setDialogState(() {
                          titleCtrl.text = preset['title']!;
                          descCtrl.text = preset['desc']!;
                        });
                      },
                      itemBuilder: (context) => funnyPresets.map((p) => PopupMenuItem(
                        value: p,
                        child: Text(p['title']!),
                      )).toList(),
                    ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g. 🦆 Duck Walk',
                    ),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'What should the user do?',
                    ),
                    maxLines: 2,
                  ),
                  TextField(
                    controller: pointsCtrl,
                    decoration: const InputDecoration(labelText: 'Points'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  onPressed: () async {
                    final challenge = ChallengeModel(
                      id: existing?.id ?? '',
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      points: int.tryParse(pointsCtrl.text) ?? 10,
                    );
                    await _service.saveChallenge(challenge);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }
  void _showQuizDialog({QuizModel? existing}) {
    final quesCtrl = TextEditingController(text: existing?.question ?? '');
    final opt1Ctrl = TextEditingController(text: (existing?.options.length ?? 0) > 0 ? existing!.options[0] : '');
    final opt2Ctrl = TextEditingController(text: (existing?.options.length ?? 0) > 1 ? existing!.options[1] : '');
    final opt3Ctrl = TextEditingController(text: (existing?.options.length ?? 0) > 2 ? existing!.options[2] : '');
    final opt4Ctrl = TextEditingController(text: (existing?.options.length ?? 0) > 3 ? existing!.options[3] : '');
    final feedCtrl = TextEditingController(text: existing?.funnyFeedback ?? 'Hah! You got it right! 😂');
    int correctIdx = existing?.correctOptionIndex ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add Funny Quiz' : 'Edit Quiz'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: quesCtrl, decoration: const InputDecoration(labelText: 'Question')),
                    TextField(controller: opt1Ctrl, decoration: const InputDecoration(labelText: 'Option 1')),
                    TextField(controller: opt2Ctrl, decoration: const InputDecoration(labelText: 'Option 2')),
                    TextField(controller: opt3Ctrl, decoration: const InputDecoration(labelText: 'Option 3')),
                    TextField(controller: opt4Ctrl, decoration: const InputDecoration(labelText: 'Option 4')),
                    const SizedBox(height: 10),
                    const Text('Correct Option:', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<int>(
                      value: correctIdx,
                      items: [0, 1, 2, 3].map((i) => DropdownMenuItem(value: i, child: Text('Option ${i + 1}'))).toList(),
                      onChanged: (val) => setDialogState(() => correctIdx = val!),
                    ),
                    TextField(controller: feedCtrl, decoration: const InputDecoration(labelText: 'Funny Feedback')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final quiz = QuizModel(
                      id: existing?.id ?? '',
                      question: quesCtrl.text.trim(),
                      options: [opt1Ctrl.text.trim(), opt2Ctrl.text.trim(), opt3Ctrl.text.trim(), opt4Ctrl.text.trim()],
                      correctOptionIndex: correctIdx,
                      funnyFeedback: feedCtrl.text.trim(),
                    );
                    await _service.saveQuiz(quiz);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.feedback), text: 'Feedback'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Challenges'),
            Tab(icon: Icon(Icons.question_answer), text: 'Quizzes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildFeedbackTab(),
          _buildChallengesTab(),
          _buildQuizzesTab(),
        ],
      ),
    );
  }
}
