import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/challenge_model.dart';
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

    // Fetch user
    UserModel? user = await _service.getUserDetails(_service.currentUser!.uid);
    
    // Fetch challenges stream
    _service.getChallenges().listen((challengesList) {
      if (mounted) {
        setState(() {
          _challenges = challengesList;
        });
      }
    });

    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  void _updateMood(String newMood) async {
    if (_user != null) {
      await _service.updateMood(_user!.uid, newMood);
      setState(() {
        _user = UserModel(
          uid: _user!.uid,
          email: _user!.email,
          name: _user!.name,
          mood: newMood,
          completedChallenges: _user!.completedChallenges,
        );
      });
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
          ],
        ),
      ),
    );
  }
}
