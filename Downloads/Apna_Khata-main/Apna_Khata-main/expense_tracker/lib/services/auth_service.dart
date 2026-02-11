import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Auth state stream
  Stream<User?> get user => _auth.authStateChanges();

  // 🔥 Google Sign In (Optimized)
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user != null) {
        // 🚀 Run Firestore profile creation in background
        _firestoreService.createUserProfile(user);
      }

      return user;
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      return null;
    }
  }

  // 🔥 Register (Optimized)
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = result.user;

      if (user != null) {
        // 🚀 DO NOT await — makes registration feel instant
        _firestoreService.createUserProfile(user);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Registration failed: ${e.message}');
      return null;
    }
  }

  // 🔥 Email Login (Optimized)
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = result.user;

      if (user != null) {
        // 🚀 Run profile setup in background
        _firestoreService.createUserProfile(user);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in failed: ${e.message}');
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Reset Password
  Future<bool> sendPasswordResetEmail() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return false;

    try {
      await _auth.sendPasswordResetEmail(email: user.email!);
      return true;
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      return false;
    }
  }

  // Delete Account
  Future<bool> deleteUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await user.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error deleting user account: ${e.code} - ${e.message}');
      return false;
    }
  }
}
