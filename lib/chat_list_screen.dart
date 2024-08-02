import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () => Navigator.pushNamed(context, '/add_friend'),
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/friend_requests'),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var user = snapshot.data!;
          var friends = List<String>.from(user['friends'] ?? []);

          if (friends.isEmpty) {
            return Center(child: Text('No friends yet.'));
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(friends[index])
                    .get(),
                builder:
                    (context, AsyncSnapshot<DocumentSnapshot> friendSnapshot) {
                  if (!friendSnapshot.hasData) {
                    return ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  var friend = friendSnapshot.data!;
                  return ListTile(
                    title: Text(friend['email']),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(peerUser: friend),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
