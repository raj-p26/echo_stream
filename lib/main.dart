import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/screens/auth.dart';
import 'package:echo_stream/screens/home.dart';
import 'package:echo_stream/screens/set_username.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late Stream<User?> authStateChanges;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    authStateChanges = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      home: StreamBuilder(
        stream: authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData) {
            return const Auth();
          }
          final userData = snapshot.data!;

          return FutureBuilder(
            future: _firestore.collection('users').doc(userData.uid).get(),
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
