import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SetUsername extends StatefulWidget {
  const SetUsername({super.key});

  @override
  State<SetUsername> createState() => _SetUsernameState();
}

class _SetUsernameState extends State<SetUsername> {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final _formKey = GlobalKey<FormState>();
  String _enteredUsername = '';

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final usersRef = _firestore.collection('users');
    final records =
        await usersRef.where('username', isEqualTo: _enteredUsername).get();

    if (records.docs.isNotEmpty) {
      _showSnackbar('Username is already taken');
      return;
    }

    _firestore.collection('users').doc(_currentUser.uid).update({
      'username': _enteredUsername,
    });
    _replaceScreen();
  }

  void _replaceScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) {
          return const Home();
        },
      ),
    );
  }

  void _showSnackbar(final String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primaryContainer,
        title: Text(
          'Give yourself a username',
          style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.exit_to_app))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  label: const Text('Enter a username'),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a valid username';
                  }

                  return null;
                },
                onSaved: (value) => _enteredUsername = value!,
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  const Spacer(),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
