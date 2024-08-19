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
                                  // imageUrl: friendData['profilePic'],
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
                                // imageUrl: friendData['profilePic'],
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
                    // ListTile(
                    //   title: Text('Groups'),
                    //   trailing: IconButton(
                    //     icon: Icon(Icons.add),
                    //     onPressed: () {
                    //       // Add functionality to create a new group
                    //     },
                    //   ),
                    // ),
                    // ...groups.map((groupId) {
                    //   return FutureBuilder<DocumentSnapshot>(
                    //     future:
                    //         _firestore.collection('groups').doc(groupId).get(),
                    //     builder: (context, groupSnapshot) {
                    //       if (!groupSnapshot.hasData) {
                    //         return ListTile(title: Text('Loading...'));
                    //       }
                    //       final groupData = groupSnapshot.data!;
                    //       return ListTile(
                    //         title: Text(groupData['name']),
                    //         onTap: () {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) =>
                    //                   GroupChatScreen(group: groupData),
                    //             ),
                    //           );
                    //         },
                    //       );
                    //     },
                    //   );
                    // }).toList(),
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
        maxLines: 1, // Limit to 1 line
        overflow: TextOverflow.ellipsis, // Show "..." for overflow
        style: TextStyle(
          fontSize: 14.0, // Make the text smaller
          color: Colors.black54, // Optional: adjust text color if needed
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style:
                TextStyle(fontSize: 12.0), // Optional: make time text smaller
          ),
          Icon(
            Icons.check_circle,
            color: isRead
                ? Colors.green
                : Colors.grey, // Green if read, grey if not read
            size: 16,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
