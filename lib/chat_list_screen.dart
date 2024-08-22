import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';
import 'group_chat_screen.dart';
import 'add_friend_screen.dart';
import 'profile_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedIndex = 0;

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 1; // Navigate to Add Friend page
          });
        },
        backgroundColor: Color.fromARGB(255, 82, 38, 230), // Your custom color
        child: Icon(Icons.person_add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.chat),
                color: _selectedIndex == 0 ? Colors.purple : Colors.grey,
                onPressed: () {
                  _onItemTapped(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.group),
                color: _selectedIndex == 2 ? Colors.purple : Colors.grey,
                onPressed: () {},
              ),
              IconButton(
                icon: SizedBox.shrink(), // Invisible widget acting as a spacer
                onPressed: null, // Disabled button
              ),
              IconButton(
                icon: Icon(Icons.call),
                color: _selectedIndex == 3 ? Colors.purple : Colors.grey,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.person),
                color: _selectedIndex == 4 ? Colors.purple : Colors.grey,
                onPressed: () {
                  _onItemTapped(4);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatListScreenContent extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Message'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
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

                          String chatRoomId =
                              getChatRoomId(_auth.currentUser!.uid, friend);

                          return StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('chats')
                                .doc(chatRoomId)
                                .collection('messages')
                                .orderBy('timestamp', descending: true)
                                .limit(1)
                                .snapshots(),
                            builder: (context, messageSnapshot) {
                              if (!messageSnapshot.hasData ||
                                  messageSnapshot.data!.docs.isEmpty) {
                                return ChatListItem(
                                  name: friendData['email'],
                                  message: 'No messages yet',
                                  time: '',
                                  isRead: true,
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
                              }

                              var recentMessageData =
                                  messageSnapshot.data!.docs.first;
                              String recentMessage = recentMessageData['text'];
                              DateTime recentMessageTime =
                                  (recentMessageData['timestamp'] as Timestamp)
                                      .toDate();
                              String formattedTime = DateFormat('hh:mm a')
                                  .format(recentMessageTime);
                              bool isRead = recentMessageData['read'] ?? false;

                              return ChatListItem(
                                name: friendData['email'],
                                message: recentMessage,
                                time: formattedTime,
                                isRead: isRead,
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
                        },
                      );
                    }).toList(),
                    Divider(),
                  ],
                );
              },
            ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool isRead;
  final String? imageUrl;
  final VoidCallback onTap;

  ChatListItem({
    required this.name,
    required this.message,
    required this.time,
    required this.isRead,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: imageUrl != null
            ? NetworkImage(imageUrl!)
            : AssetImage('assets/default_profile.png') as ImageProvider,
      ),
      title: Text(name),
      subtitle: Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.black54,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: TextStyle(fontSize: 12.0),
          ),
          Icon(
            Icons.check_circle,
            color: isRead ? Colors.green : Colors.grey,
            size: 16,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
