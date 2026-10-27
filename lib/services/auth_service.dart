import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

/// All Firebase Authentication + Realtime Database logic for sign up / login.
///
/// Auth      -> email + password accounts (Firebase Authentication)
/// Database  -> profile of each student at:  users/{uid}
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _users = FirebaseDatabase.instance.ref('users');

  /// Emits the current user whenever someone logs in or out.
  Stream<User?> get authChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Creates the Auth account, then saves the profile at users/{uid}.
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;

    try {
      await _users.child(user.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'createdAt': ServerValue.timestamp,
        'lastLoginAt': ServerValue.timestamp,
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      // Database write failed (rules / wrong databaseURL / offline):
      // remove the Auth account so there is no login without a profile.
      await user.delete();
      rethrow;
    }
  }

  Future<void> login({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Record the login. update() also recreates a partial profile if the
    // account was made outside the app (e.g. in the Firebase console).
    // A failure here should not block a successful login.
    try {
      await _users.child(cred.user!.uid).update({
        'email': cred.user!.email,
        'lastLoginAt': ServerValue.timestamp,
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Could not update lastLoginAt: $e');
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  /// Turns Firebase error codes into messages a student can understand.
  static String errorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in Firebase.';
      default:
        return 'Something went wrong: ${e.code}';
    }
  }
}
