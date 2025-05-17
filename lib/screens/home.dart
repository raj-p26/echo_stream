import 'package:echo_stream/screens/tabs/home_tab.dart';
import 'package:echo_stream/screens/tabs/profile_tab.dart';
import 'package:echo_stream/screens/tabs/search_tab.dart';
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
    switch (index) {
      case 0:
        setState(() {
          _currentTab = HomeTab();
        });
        break;
      case 1:
        setState(() {
          _currentTab = SearchTab();
        });
      case 2:
        setState(() {
          _currentTab = ProfileTab(userID: _currentUser.uid);
        });
      default:
        setState(() {
          _currentTab = HomeTab();
        });
    }
  }

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
      body: _currentTab,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: _changeScreen,
      ),
    );
  }
}
