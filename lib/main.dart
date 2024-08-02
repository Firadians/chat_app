import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'chat_list_screen.dart';
import 'notification_service.dart';
import 'add_friend_screen.dart';
import 'friend_requests_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? LoginScreen()
          : ChatListScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/chat': (context) => ChatListScreen(),
        '/add_friend': (context) => AddFriendScreen(),
        '/friend_requests': (context) => FriendRequestsScreen(),
      },
    );
  }
}
