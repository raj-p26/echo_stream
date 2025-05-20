import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _currentUser = UserRepository.currentUser!;
  final _userRepository = UserRepository();
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  final TextEditingController _nameController = TextEditingController(),
      _bioController = TextEditingController();

  void _updateProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnackbar('Name cannot be empty');
      return;
    }
    final bio = _bioController.text.trim();

    await _userRepository.updateUser(_currentUser.uid, {
      'fullName': name,
      'bio': bio,
    });
    if (mounted) Navigator.pop(context);
  }

  void _showSnackbar(final String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void initState() {
    super.initState();
    _userStream = _userRepository.getUserSnapshot(_currentUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [TextButton(onPressed: _updateProfile, child: Text('Update'))],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StreamBuilder(
          stream: _userStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: LinearProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            if (snapshot.data == null) {
              return const Center(child: Text('No data'));
            }

            final data = snapshot.data!;
            _nameController.text = data['fullName'];
            _bioController.text = data['bio'];

            return Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(label: Text('Name')),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    label: Text('Bio'),
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
