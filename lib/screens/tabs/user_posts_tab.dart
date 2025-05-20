import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/repositories/post_repository.dart';
import 'package:echo_stream/screens/see_post.dart';
import 'package:echo_stream/widgets/post_card.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

class UserPostsTab extends StatefulWidget {
  const UserPostsTab({super.key, required this.userID});
  final String userID;

  @override
  State<UserPostsTab> createState() => _UserPostsTabState();
}

class _UserPostsTabState extends State<UserPostsTab> {
  late Query<Map<String, dynamic>> _postsQuery;

  @override
  void initState() {
    super.initState();
    _postsQuery = PostRepository().postsCollection.where(
      'postCreatorID',
      isEqualTo: widget.userID,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreListView(
      query: _postsQuery,
      itemBuilder: (ctx, doc) {
        return PostCard(
          key: Key(doc.id),
          postID: doc.id,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (builderContext) => SeePost(postID: doc.id),
              ),
            );
          },
        );
      },
    );
  }
}
