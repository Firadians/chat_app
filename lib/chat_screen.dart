import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
  static const appId =
      'c85fe25e3dc8483d837904b754cfd912'; // Replace with your Agora App ID
  static const token = null; // Token can be set to null for now
  late final RtcEngine _engine;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String filePath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(toFile: filePath);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    String? filePath = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _recordedFilePath = filePath;
    });
    if (filePath != null) {
      _sendVoiceMessage(filePath);
    }
  }

  Future<void> _sendVoiceMessage(String filePath) async {
    File voiceFile = File(filePath);
    String chatRoomId =
        getChatRoomId(_auth.currentUser!.uid, widget.peerUser['uid']);

    // Upload the voice note to Firebase Storage (you need to implement this part)
    // Store the download URL in Firestore along with other message details
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'voiceUrl':
          filePath, // Replace with the actual download URL after uploading
      'senderId': _auth.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'type':
          'voice', // New field to differentiate between text and voice messages
    });

    _scrollToBottom();
  }

  void _playVoiceMessage(String url) async {
    if (_player.isPlaying) {
      await _player.stopPlayer();
    } else {
      await _player.startPlayer(fromURI: url);
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  String getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }

  void _initAgora() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print(
              'Joined channel: ${connection.channelId}, with uid: ${connection.localUid}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print('User joined: $remoteUid');
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print('User offline: $remoteUid');
        },
      ),
    );
  }

  void _startCall() async {
    String chatRoomId =
        getChatRoomId(_auth.currentUser!.uid, widget.peerUser['uid']);
    await _engine.joinChannel(
      token: token ?? "",
      channelId: chatRoomId,
      uid: 0,
      options: ChannelMediaOptions(),
    );
  }

  void _endCall() async {
    await _engine.leaveChannel();
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
        'type': 'text',
      });
      _controller.clear();
      _scrollToBottom();
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
            icon: Icon(Icons.call),
            onPressed: _startCall,
          ),
          IconButton(
            icon: Icon(Icons.call_end),
            onPressed: _endCall,
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
                    String messageType = message['type'] ?? 'text';

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
                              if (messageType == 'text')
                                Text(
                                  message['text'],
                                  style: TextStyle(
                                      color:
                                          isMe ? Colors.white : Colors.black),
                                  softWrap: true, // Support multi-line display
                                ),
                              if (messageType == 'voice')
                                IconButton(
                                  icon: Icon(Icons.play_arrow),
                                  onPressed: () =>
                                      _playVoiceMessage(message['voiceUrl']),
                                  color: isMe ? Colors.white : Colors.black,
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
                  icon: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  color: _isRecording ? Colors.red : null,
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
