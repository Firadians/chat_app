import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddGroupMemberScreen extends StatefulWidget {
  final String groupId;

  AddGroupMemberScreen({required this.groupId});

  @override
  _AddGroupMemberScreenState createState() => _AddGroupMemberScreenState();
}

class _AddGroupMemberScreenState extends State<AddGroupMemberScreen> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addMember() async {
    final email = _emailController.text.trim();

    if (email.isNotEmpty) {
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (result.docs.isNotEmpty) {
        final user = result.docs.first;

        await _firestore.collection('groups').doc(widget.groupId).update({
          'members': FieldValue.arrayUnion([user['uid']]),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$email added to the group'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User with email $email not found'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Group Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Member\'s Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMember,
              child: Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }
}
