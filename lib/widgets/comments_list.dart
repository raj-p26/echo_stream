import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/widgets/comment_list_tile.dart';
import 'package:flutter/material.dart';

class CommentsList extends StatefulWidget {
  const CommentsList({super.key, required this.postID});

  final String postID;

  @override
  State<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends State<CommentsList> {
  final _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _postStream;

  @override
  void initState() {
    super.initState();
    _postStream = _firestore.collection('posts').doc(widget.postID).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _postStream,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null || snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final postData = snapshot.data;

        if (postData == null) {
          return const Text('No data');
        }

        final comments = postData['comments'].reversed.toList();

        if (comments.length == 0) {
          return const Text('No comments yet');
        }

        return ListView.separated(
          itemCount: comments.length,
          itemBuilder: (listContext, idx) {
            final commentID = comments[idx];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CommentListTile(commentID: commentID, key: Key(commentID)),
            );
          },
          separatorBuilder: (listContext, idx) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Divider(),
            );
          },
        );
      },
    );
  }
}
