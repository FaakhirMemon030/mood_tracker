import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/challenge_model.dart';
import '../models/feedback_model.dart';
import '../models/admin_details.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth changes
  Stream<User?> get user => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Sign up
  Future<String?> signUp(String email, String password, String name) async {
    try {
      if (email == AdminDetails.email) {
        return 'Cannot sign up as admin.';
      }
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (cred.user != null) {
        UserModel userModel = UserModel(
          uid: cred.user!.uid,
          email: email,
          name: name,
        );
        await _firestore.collection('users').doc(cred.user!.uid).set(userModel.toMap());
        return null; // Success
      }
      return 'Unknown error occurred.';
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Log in
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      // Check if user is banned (if not admin)
      if (email != AdminDetails.email && _auth.currentUser != null) {
        var doc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
        if (doc.exists && (doc.data()?['isBanned'] ?? false) == true) {
          await _auth.signOut();
          return 'Your account has been banned.';
        }
      }
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user details
  Future<UserModel?> getUserDetails(String uid) async {
    var doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Stream of current user data
  Stream<UserModel?> userStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Update Mood
  Future<void> updateMood(String uid, String mood) async {
    await _firestore.collection('users').doc(uid).update({'mood': mood});
  }

  // Complete Challenge
  Future<void> completeChallenge(String uid, String challengeId) async {
    await _firestore.collection('users').doc(uid).update({
      'completedChallenges': FieldValue.arrayUnion([challengeId])
    });
  }

  // Submit Feedback
  Future<void> submitFeedback(String uid, String message) async {
    await _firestore.collection('feedback').add({
      'uid': uid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Admin Methods
  
  // Get all users
  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Ban/Unban user
  Future<void> toggleBanStatus(String uid, bool currentStatus) async {
    await _firestore.collection('users').doc(uid).update({'isBanned': !currentStatus});
  }

  // Get all feedback
  Stream<List<FeedbackModel>> getAllFeedback() {
    return _firestore.collection('feedback').orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FeedbackModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Challenges Stream
  Stream<List<ChallengeModel>> getChallenges() {
    return _firestore.collection('challenges').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ChallengeModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Add/Edit Challenge
  Future<void> saveChallenge(ChallengeModel challenge) async {
    if (challenge.id.isEmpty) {
      await _firestore.collection('challenges').add(challenge.toMap());
    } else {
    }
  }

  // Delete Challenge
  Future<void> deleteChallenge(String id) async {
    await _firestore.collection('challenges').doc(id).delete();
  }

  // --- Quizzes ---

  Stream<List<QuizModel>> getQuizzes() {
    return _firestore.collection('quizzes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => QuizModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> saveQuiz(QuizModel quiz) async {
    if (quiz.id.isEmpty) {
      await _firestore.collection('quizzes').add(quiz.toMap());
    } else {
      await _firestore.collection('quizzes').doc(quiz.id).update(quiz.toMap());
    }
  }

  Future<void> deleteQuiz(String id) async {
    await _firestore.collection('quizzes').doc(id).delete();
  }

  Future<void> completeQuiz(String uid, String quizId, int points) async {
    await _firestore.collection('users').doc(uid).update({
      'completedQuizzes': FieldValue.arrayUnion([quizId]),
      'score': FieldValue.increment(points),
    });
  }
}
