import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  String? _errorMessage;

  void _sendFriendRequest() async {
    String currentUserEmail = _auth.currentUser?.email ?? '';
    String enteredEmail = _emailController.text;

    if (enteredEmail.isEmpty) {
      setState(() {
        _errorMessage = "Please enter an email";
      });
      return;
    }

    try {
      // Find the user by email
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: enteredEmail)
          .get();

      if (userSnapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = "User not found";
        });
        return;
      }

      String toUid = userSnapshot.docs.first['uid'];
      String fromUid = _auth.currentUser!.uid;

      // Check if a friend request already exists
      QuerySnapshot requestSnapshot = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('from_uid', isEqualTo: fromUid)
          .where('to_uid', isEqualTo: toUid)
          .where('status', isEqualTo: 'pending')
          .get();

      if (requestSnapshot.docs.isNotEmpty) {
        setState(() {
          _errorMessage = "Friend request already sent";
        });
        return;
      }

      // Create a new friend request
      await FirebaseFirestore.instance.collection('friend_requests').add({
        'from_uid': fromUid,
        'to_uid': toUid,
        'status': 'pending',
      });

      setState(() {
        _errorMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Friend request sent")),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Enter email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendFriendRequest,
              child: Text('Send Friend Request'),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
