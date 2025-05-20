import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/repositories/user_repository.dart';
import 'package:echo_stream/widgets/post_headline.dart';
import 'package:flutter/material.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _userRepository = UserRepository();
  final _usernameController = TextEditingController();
  late Stream<QuerySnapshot<Map<String, dynamic>>> _randomUsersList;

  @override
  void initState() {
    super.initState();
    _randomUsersList = _userRepository.randomUsers;
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
      _randomUsersList = _userRepository.getUserByUsername(username);
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
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              label: const Text('Search'),
              prefix: const Text('@'),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _randomUsersList,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No Data'));
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No user found.'));
                }

                docs.shuffle();
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (listCtx, idx) {
                    return PostHeadline(userID: docs[idx].id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
