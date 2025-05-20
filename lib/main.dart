import 'package:echo_stream/repositories/user_repository.dart';
import 'package:echo_stream/screens/auth.dart';
import 'package:echo_stream/screens/home.dart';
import 'package:echo_stream/screens/set_username.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _userRepo = UserRepository();
  final _authStateChanges = UserRepository.userAuthStream;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      home: StreamBuilder(
        stream: _authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData) return const Auth();

          final userData = snapshot.data!;

          return FutureBuilder(
            future: _userRepo.getUserDocByID(userData.uid),
            builder: (ctx, userInfoSnapshot) {
              if (userInfoSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: const Center(child: CircularProgressIndicator()),
                );
              }
              final userInfo = userInfoSnapshot.data!.data();
              if (userInfo == null || userInfo['username'] == null) {
                return SetUsername();
              }

              return const Home();
            },
          );
        },
      ),
    );
  }
}
