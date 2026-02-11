import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/models/user_profile_model.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- CORRECTED METHOD ---
  /// Gets a real-time stream of the current user's expenses.
  /// It safely handles the user being logged in or out.
  Stream<List<Expense>> getExpensesStream() {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        // If the user is logged out, return a stream with an empty list.
        return Stream.value(<Expense>[]);
      } else {
        // If the user is logged in, return the stream of their expenses.
        return _db
            .collection('users')
            .doc(user.uid)
            .collection('expenses')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .map((snapshot) =>
                snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
      }
    });
  }

  Future<void> addExpense(String item, double amount, String category) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('expenses').add({
      'item': item,
      'amount': amount,
      'category': category,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteExpense(String expenseId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  // --- User Profile Methods ---

  Future<void> createUserProfile(User user) async {
    final userRef = _db.collection('users').doc(user.uid);
    final doc = await userRef.get();
    if (!doc.exists) {
      await userRef.set({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'phoneNumber': null,
        'dateOfBirth': null,
      });
    }
  }

  Stream<UserProfile> getUserProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.error('User not logged in.');
    }
    return _db.collection('users').doc(user.uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw 'Profile document does not exist for this user.';
      }
      return UserProfile.fromFirestore(snapshot);
    });
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).update(profile.toFirestore());
  }
}