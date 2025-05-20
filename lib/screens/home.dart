import 'package:echo_stream/repositories/user_repository.dart';
import 'package:echo_stream/screens/tabs/home_tab.dart';
import 'package:echo_stream/screens/tabs/profile_tab.dart';
import 'package:echo_stream/screens/tabs/search_tab.dart';
import 'package:echo_stream/screens/tabs/settings_tab.dart';
import 'package:echo_stream/screens/update_profile.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _currentUser = UserRepository.currentUser!;

  static const bottomNavigationBarItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];
  Widget _currentTab = HomeTab();
  int _currentTabIndex = 0;

  void _changeScreen(int index) {
    _currentTabIndex = index;
    setState(() {
      _currentTab = switch (index) {
        1 => SearchTab(),
        2 => SettingsTab(),
        3 => ProfileTab(userID: _currentUser.uid),
        _ => HomeTab(),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EchoStream'),
        actions: [
          if (_currentTabIndex == 3)
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
        ],
      ),
      body: _currentTab,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        type: BottomNavigationBarType.fixed,
        items: bottomNavigationBarItems,
        onTap: _changeScreen,
      ),
    );
  }
}
