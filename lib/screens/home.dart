import 'package:echo_stream/screens/tabs/home_tab.dart';
import 'package:echo_stream/screens/tabs/profile_tab.dart';
import 'package:echo_stream/screens/tabs/search_tab.dart';
import 'package:echo_stream/screens/update_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  Widget _currentTab = HomeTab();
  int _currentTabIndex = 0;

  void _changeScreen(int index) {
    _currentTabIndex = index;

    setState(() {
      _currentTab = switch (index) {
        0 => HomeTab(),
        1 => SearchTab(),
        2 => ProfileTab(userID: _currentUser.uid),
        _ => HomeTab(),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text('EchoStream'),
        actions: [
          if (_currentTabIndex == 2)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (routerCtx) => UpdateProfile()),
                );
              },
              tooltip: 'Edit profile',
              icon: const Icon(Icons.edit_outlined),
            ),
          IconButton(
            onPressed: () async {
              await firebaseAuth.signOut();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: _currentTab,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: _changeScreen,
      ),
    );
  }
}
