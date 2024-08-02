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
        title: Text(widget.peerUser['email']),
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
                            color: isMe ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
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
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Enter your message'),
                    onSubmitted: (_) => _sendMessage(),
                  ),
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
