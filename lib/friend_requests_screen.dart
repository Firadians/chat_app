import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final _auth = FirebaseAuth.instance;

  void _handleFriendRequest(
      String requestId, String fromUid, bool isAccepted) async {
    String currentUserUid = _auth.currentUser!.uid;

    if (isAccepted) {
      // Add each other as friends
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .update({
        'friends': FieldValue.arrayUnion([fromUid]),
      });

      await FirebaseFirestore.instance.collection('users').doc(fromUid).update({
        'friends': FieldValue.arrayUnion([currentUserUid]),
      });
    }

    // Update the friend request status
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(requestId)
        .update({
      'status': isAccepted ? 'accepted' : 'rejected',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('friend_requests')
            .where('to_uid', isEqualTo: _auth.currentUser!.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var requests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              return ListTile(
                title: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(request['from_uid'])
                      .get(),
                  builder:
                      (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return Text('Loading...');
                    }
                    return Text(userSnapshot.data!['email']);
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () => _handleFriendRequest(
                          request.id, request['from_uid'], true),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => _handleFriendRequest(
                          request.id, request['from_uid'], false),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
