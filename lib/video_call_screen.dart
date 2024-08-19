// import 'package:flutter/material.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:permission_handler/permission_handler.dart';

// class VideoCallScreen extends StatefulWidget {
//   final String channelId;

//   const VideoCallScreen({required this.channelId});

//   @override
//   _VideoCallScreenState createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   late final RtcEngine _engine;
//   bool _localUserJoined = false;

//   @override
//   void initState() {
//     super.initState();
//     _initAgora();
//   }

//   Future<void> _initAgora() async {
//     // Get permissions for camera and microphone
//     await [Permission.microphone, Permission.camera].request();

//     // Initialize Agora Engine
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(RtcEngineContext(
//       appId: 'YOUR_APP_ID', // Replace with your Agora App ID
//     ));

//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         joinChannelSuccess: (connection, uid, elapsed) {
//           setState(() {
//             _localUserJoined = true;
//           });
//         },
//         userJoined: (connection, remoteUid, elapsed) {
//           setState(() {
//             // Handle remote user joining the channel
//           });
//         },
//         userOffline: (connection, remoteUid, reason) {
//           setState(() {
//             // Handle remote user leaving the channel
//           });
//         },
//       ),
//     );

//     await _engine.enableVideo();

//     // Join the Agora channel
//     await _engine.joinChannel(
//       token: null, // Add token if required, otherwise null for testing
//       channelId: widget.channelId,
//       uid: 0, // Local user ID, set to 0 for auto allocation
//       options: ChannelMediaOptions(),
//     );
//   }

//   @override
//   void dispose() {
//     _engine.leaveChannel();
//     _engine.release();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Video Call')),
//       body: Stack(
//         children: [
//           _localUserJoined
//               ? AgoraVideoView(
//                   controller: VideoViewController(
//                       rtcEngine: _engine, canvas: VideoCanvas(uid: 0)))
//               : Center(child: CircularProgressIndicator()),
//           Align(
//             alignment: Alignment.topRight,
//             child: Container(
//               width: 120,
//               height: 160,
//               child: AgoraVideoView(
//                   controller: VideoViewController(
//                       rtcEngine: _engine, canvas: VideoCanvas(uid: 0))),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
