import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text('EchoStream'),
        actions: [
          IconButton(
            onPressed: () async {
              await firebaseAuth.signOut();
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Center(
        child: Text('Logged in as ${firebaseAuth.currentUser?.email}'),
      ),
    );
  }
}
