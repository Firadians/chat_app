import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String username;
  final List<String> friends;
  final String profilePictureUrl; // New field for profile picture URL
  final String bio; // New field for bio

  const UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.friends = const [],
    this.profilePictureUrl = '', // Default value for profile picture URL
    this.bio = '', // Default value for bio
  });

  @override
  List<Object> get props =>
      [uid, email, username, friends, profilePictureUrl, bio];

  // Factory method to create a UserModel from Firebase User
  factory UserModel.fromFirebaseUser(User user, {required String username}) {
    return UserModel(
      uid: user.uid,
      email: user.email!,
      username: username,
    );
  }

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'friends': friends,
      'profilePictureUrl': profilePictureUrl, // Include profile picture URL
      'bio': bio, // Include bio
    };
  }

  // Factory method to create a UserModel from Firestore DocumentSnapshot
  factory UserModel.fromDocumentSnapshot(Map<String, dynamic> doc) {
    return UserModel(
      uid: doc['uid'] as String,
      email: doc['email'] as String,
      username: doc['username'] as String,
      friends: List<String>.from(doc['friends'] ?? []),
      profilePictureUrl:
          doc['profilePictureUrl'] ?? '', // Assign profile picture URL
      bio: doc['bio'] ?? '', // Assign bio
    );
  }
}
