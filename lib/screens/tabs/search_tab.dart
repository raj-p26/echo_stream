import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/repositories/user_repository.dart';
import 'package:echo_stream/widgets/post_headline.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _userRepository = UserRepository();
  final _usernameController = TextEditingController();
  late Query<Map<String, dynamic>> _randomUsersList;

  @override
  void initState() {
    super.initState();
    _randomUsersList = _userRepository.usersCollection;
  }

  void _searchUser() {
    final username = _usernameController.text.toString();
    _usernameController.clear();

    if (username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Username cannot be empty')));
      return;
    }

    setState(() {
      _randomUsersList = _userRepository.usersCollection.where(
        'username',
        isEqualTo: username,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _usernameController,
            onSubmitted: (_) => _searchUser(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text('Search'),
              prefix: Text('@'),
            ),
          ),
          Expanded(
            child: FirestoreListView(
              query: _randomUsersList,
              itemBuilder: (ctx, doc) => PostHeadline(userID: doc.id),
            ),
          ),
        ],
      ),
    );
  }
}
