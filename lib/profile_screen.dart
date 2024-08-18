import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: currentUser == null
          ? Center(child: Text('Not logged in'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${currentUser.email}'),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      await _auth.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text('Sign Out'),
                  ),
                ],
              ),
            ),
    );
  }
}
