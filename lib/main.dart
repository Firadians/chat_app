import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_screen.dart';
import 'bloc/login_bloc.dart';
import 'register_screen.dart';
import 'bloc/register_bloc.dart';
import 'notification_service.dart';
import 'add_friend_screen.dart';
import 'friend_requests_screen.dart';
import 'chat_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Create the custom color swatch
  final Map<int, Color> color = {
    50: Color.fromRGBO(82, 38, 230, .1),
    100: Color.fromRGBO(82, 38, 230, .2),
    200: Color.fromRGBO(82, 38, 230, .3),
    300: Color.fromRGBO(82, 38, 230, .4),
    400: Color.fromRGBO(82, 38, 230, .5),
    500: Color.fromRGBO(82, 38, 230, .6),
    600: Color.fromRGBO(82, 38, 230, .7),
    700: Color.fromRGBO(82, 38, 230, .8),
    800: Color.fromRGBO(82, 38, 230, .9),
    900: Color.fromRGBO(82, 38, 230, 1),
  };
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(),
        ),
        BlocProvider(
          create: (context) => RegisterBloc(),
          child: RegisterScreen(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Chat App',
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFF5226E6, color),
        ),
        home: FirebaseAuth.instance.currentUser == null
            ? LoginScreen()
            : ChatListScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/chat': (context) => ChatListScreen(),
          '/add_friend': (context) => AddFriendScreen(),
          '/friend_requests': (context) => FriendRequestsScreen(),
        },
      ),
    );
  }
}
