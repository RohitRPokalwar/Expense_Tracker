import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final Timestamp? dateOfBirth;
  final String? photoURL;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.dateOfBirth,
    this.photoURL,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    // A null check to prevent crashes if the document doesn't exist or is empty
    if (data == null) {
      throw 'User profile data is null!';
    }
    return UserProfile(
      uid: snapshot.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      dateOfBirth: data['dateOfBirth'],
      photoURL: data['photoURL'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'photoURL': photoURL,
    };
  }
}