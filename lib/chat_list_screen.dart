import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'group_chat_screen.dart';
import 'add_friend_screen.dart';
import 'profile_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedIndex = 0;

  // Correct usage without `const`
  static final List<Widget> _pages = <Widget>[
    ChatListScreenContent(),
    AddFriendScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      // Correct usage without `const`
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Add Friend',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ChatListScreenContent extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              Navigator.pushNamed(context, '/add_friend');
            },
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
      body: currentUser == null
          ? Center(child: Text('Not logged in'))
          : StreamBuilder(
              stream: _firestore
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final friends = userData['friends'] as List<dynamic>? ?? [];
                final groups = userData['groups'] as List<dynamic>? ?? [];

                return ListView(
                  children: <Widget>[
                    ListTile(
                      title: Text('Friends'),
                      trailing: IconButton(
                        icon: Icon(Icons.group_add),
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_friend');
                        },
                      ),
                    ),
                    ...friends.map((friend) {
                      return FutureBuilder<DocumentSnapshot>(
                        future:
                            _firestore.collection('users').doc(friend).get(),
                        builder: (context, friendSnapshot) {
                          if (!friendSnapshot.hasData) {
                            return ListTile(title: Text('Loading...'));
                          }
                          final friendData = friendSnapshot.data!;
                          return ListTile(
                            title: Text(friendData['email']),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChatScreen(peerUser: friendData),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                    Divider(),
                    ListTile(
                      title: Text('Groups'),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          // Add functionality to create a new group
                        },
                      ),
                    ),
                    ...groups.map((groupId) {
                      return FutureBuilder<DocumentSnapshot>(
                        future:
                            _firestore.collection('groups').doc(groupId).get(),
                        builder: (context, groupSnapshot) {
                          if (!groupSnapshot.hasData) {
                            return ListTile(title: Text('Loading...'));
                          }
                          final groupData = groupSnapshot.data!;
                          return ListTile(
                            title: Text(groupData['name']),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GroupChatScreen(group: groupData),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  ],
                );
              },
            ),
    );
  }
}
