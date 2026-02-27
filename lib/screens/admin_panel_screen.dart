import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/feedback_model.dart';
import '../models/challenge_model.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(challenge.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(challenge.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showChallengeDialog(existing: challenge),
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Challenge' : 'Edit Challenge'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final challenge = ChallengeModel(
                  id: existing?.id ?? '', // empty id will let firebase generate one
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                );
                await _service.saveChallenge(challenge);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildFeedbackTab(),
          _buildChallengesTab(),
        ],
      ),
    );
  }
}
