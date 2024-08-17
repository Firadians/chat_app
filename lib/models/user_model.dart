import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final List<String> friends;

  const UserModel({
    required this.uid,
    required this.email,
    this.friends = const [],
  });

  @override
  List<Object> get props => [uid, email, friends];

  // Factory method to create a UserModel from Firebase User
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email!,
    );
  }

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'friends': friends,
    };
  }
}
