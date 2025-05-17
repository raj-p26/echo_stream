import 'package:echo_stream/screens/tabs/profile_tab.dart';
import 'package:flutter/material.dart';

class SeeProfile extends StatefulWidget {
  const SeeProfile({super.key, required this.userID});
  final String userID;

  @override
  State<SeeProfile> createState() => _SeeProfileState();
}

class _SeeProfileState extends State<SeeProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Profile')),
      body: ProfileTab(userID: widget.userID),
    );
  }
}
