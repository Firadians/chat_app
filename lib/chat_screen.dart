import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final DocumentSnapshot peerUser;

  ChatScreen({required this.peerUser});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  String getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      String chatRoomId =
          getChatRoomId(_auth.currentUser!.uid, widget.peerUser['uid']);
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'text': _controller.text,
        'senderId': _auth.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
      _controller.clear();
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String chatRoomId =
        getChatRoomId(_auth.currentUser!.uid, widget.peerUser['uid']);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.peerUser['email'],
              style: TextStyle(fontSize: 16),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.peerUser['uid'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    'Loading...',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'Error',
                    style: TextStyle(fontSize: 12, color: Colors.redAccent),
                  );
                } else {
                  return Text(
                    'No status...',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  );
                }

                bool isOnline = snapshot.data?['isOnline'] ?? false;

                return Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline ? Colors.greenAccent : Colors.white70,
                  ),
                );
              },
            ),
          ],
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.video_call),
            onPressed: () {
              // Implement video call functionality
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == _auth.currentUser!.uid;
                    DateTime timestamp = message['timestamp'] != null
                        ? (message['timestamp'] as Timestamp).toDate()
                        : DateTime.now();
                    String time = DateFormat('hh:mm a').format(timestamp);
                    bool isRead = (message.data() as Map<String, dynamic>)
                            .containsKey('read')
                        ? message['read']
                        : false;

                    if (!isMe && !isRead) {
                      message.reference.update({'read': true});
                    }

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Color.fromARGB(255, 82, 38, 230)
                                : const Color.fromARGB(255, 244, 244, 244),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                message['text'],
                                style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black),
                                softWrap: true, // Support multi-line display
                              ),
                              SizedBox(height: 5),
                              Text(
                                time,
                                style: TextStyle(
                                    color:
                                        isMe ? Colors.white70 : Colors.black54,
                                    fontSize: 12),
                              ),
                              SizedBox(height: 5),
                              if (isMe)
                                Text(
                                  isRead ? 'Read' : 'Sent',
                                  style: TextStyle(
                                      color: isMe
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // Implement functionality for adding attachments
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Enter your message'),
                    maxLines: null, // Allow multi-line input
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: () {
                    // Implement voice message functionality
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
