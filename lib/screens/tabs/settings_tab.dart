import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _firebaseAuth = FirebaseAuth.instance;

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _firebaseAuth.signOut();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordResetDialog() async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: const Text(
            'Your password reset link has been sent to your email.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
    final currentUser = _firebaseAuth.currentUser!;
    await _firebaseAuth.sendPasswordResetEmail(email: currentUser.email!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: _showPasswordResetDialog,
            child: const Text('Reset password'),
          ),
          TextButton(
            onPressed: _confirmLogout,
            child: Text(
              'Logout',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
