import 'package:echo_stream/repositories/post_repository.dart';
import 'package:echo_stream/screens/see_post.dart';
import 'package:echo_stream/widgets/post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _postRepository = PostRepository();
  final _currentUser = FirebaseAuth.instance.currentUser!;

  final _postTextController = TextEditingController();
  bool _isSubmitting = false;

  void _createPost() async {
    setState(() => _isSubmitting = true);

    final text = _postTextController.text.trim();
    if (text.isEmpty) {
      _showSnackbar('Post body cannot be empty');
      setState(() => _isSubmitting = false);
      return;
    }

    await _postRepository.createPost(
      creatorID: _currentUser.uid,
      content: text,
    );

    setState(() => _isSubmitting = false);

    _postTextController.clear();
    if (mounted) Navigator.pop(context);
  }

  void _showSnackbar(final String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final ThemeData theme = Theme.of(context);

        return SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30.0),
              AppBar(
                title: const Text('Say Something'),
                backgroundColor: theme.colorScheme.surfaceContainerLow,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _postTextController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('What\'s happening?'),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    const Spacer(),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _createPost,
                      child: const Text('Post'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _seePostScreen(final String postID) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => SeePost(postID: postID)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openBottomSheet,
        child: const Icon(Icons.add),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: FirestoreListView(
          query: _postRepository.postsCollection,
          itemBuilder: (ctx, doc) {
            return PostCard(
              key: Key(doc.id),
              postID: doc.id,
              onPressed: () {
                _seePostScreen(doc.id);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _postTextController.dispose();
  }
}
