import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/challenge_model.dart';
import 'quiz_screen.dart';
import 'widgets/mood_slider.dart';
import 'widgets/funny_challenges.dart';
import 'feedback_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _service = FirebaseService();
  UserModel? _user;
  List<ChallengeModel> _challenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    if (_service.currentUser == null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    // Fetch user stream
    _service.userStream(_service.currentUser!.uid).listen((user) {
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    });
    
    // Fetch challenges stream
    _service.getChallenges().listen((challengesList) {
      if (mounted) {
        setState(() {
          _challenges = challengesList;
        });
      }
    });
  }

  void _updateMood(String newMood) async {
    if (_user != null) {
      await _service.updateMood(_user!.uid, newMood);
    }
  }

  void _completeChallenge(String challengeId) async {
    if (_user != null) {
      await _service.completeChallenge(_user!.uid, challengeId);
      
      // Local update for UI
      setState(() {
        _user!.completedChallenges.add(challengeId);
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge Completed! Great job!'), backgroundColor: Colors.green),
      );
    }
  }

  void _logout() async {
    await _service.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: SpinKitWave(color: Theme.of(context).primaryColor, size: 30.0)));
    }

    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load user data or you are banned.'),
              ElevatedButton(onPressed: _logout, child: const Text('Back to Login'))
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.feedback),
            tooltip: 'Provide Feedback',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome back, ${_user!.name}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Your Score: 💰 ${_user!.score}',
              style: const TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Mood Slider
            MoodSlider(
              currentMood: _user!.mood,
              onMoodChanged: _updateMood,
            ),
            
            const SizedBox(height: 30),
            const Text(
              'Funny Challenges',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Funny Challenges
            FunnyChallenges(
              challenges: _challenges,
              completedIds: _user!.completedChallenges,
              onComplete: _completeChallenge,
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              icon: const Icon(Icons.question_answer),
              label: const Text('Play Funny Quizzes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QuizScreen(userId: _user!.uid)),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
