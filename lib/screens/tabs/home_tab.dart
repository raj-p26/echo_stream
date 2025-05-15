import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/screens/see_post.dart';
import 'package:echo_stream/widgets/post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser!;
  late Stream<QuerySnapshot<Map<String, dynamic>>> postsStream;

  final _postTextController = TextEditingController();
  bool _isSubmitting = false;

  void _createPost() async {
    setState(() {
      _isSubmitting = true;
    });

    final text = _postTextController.text.trim();
    if (text.isEmpty) {
      _showSnackbar('Post body cannot be empty');
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    await _firestore.collection('posts').add({
      'postCreatorID': _currentUser.uid,
      'postContent': text,
      'likes': [],
      'comments': [],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
    setState(() {
      _isSubmitting = false;
    });

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
  void initState() {
    super.initState();
    postsStream =
        _firestore
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openBottomSheet,
        child: Icon(Icons.add),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: StreamBuilder(
          stream: postsStream,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: const CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final posts = snapshot.data!.docs;

            if (posts.isEmpty) {
              return const Center(child: Text('No posts found'));
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (listCtx, idx) {
                return PostCard(
                  key: Key(posts[idx].id),
                  postID: posts[idx].id,
                  onPressed: _seePostScreen,
                );
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
