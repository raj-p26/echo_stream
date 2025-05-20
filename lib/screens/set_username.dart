import 'package:echo_stream/repositories/user_repository.dart';
import 'package:echo_stream/screens/home.dart';
import 'package:flutter/material.dart';

class SetUsername extends StatefulWidget {
  const SetUsername({super.key});

  @override
  State<SetUsername> createState() => _SetUsernameState();
}

class _SetUsernameState extends State<SetUsername> {
  final _currentUser = UserRepository.currentUser!;
  final _userRepository = UserRepository();
  final _formKey = GlobalKey<FormState>();
  String _enteredUsername = '';
  String _enteredBio = '';

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final exists = await _userRepository.usernameExists(_enteredUsername);

    if (exists) {
      _showSnackbar('Username is already taken');
      return;
    }

    await _userRepository.updateUser(_currentUser.uid, {
      'username': _enteredUsername,
      'bio': _enteredBio,
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
          'Set up your profile',
          style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
        ),
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

                  if (value.contains(' ')) {
                    return 'Username must not have any spaces or special characters';
                  }

                  return null;
                },
                onSaved: (value) => _enteredUsername = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Bio'),
                ),
                onSaved: (value) => _enteredBio = value ?? '',
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
