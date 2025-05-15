import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/models/comment.dart';
import 'package:echo_stream/widgets/labelled_icon_button.dart';
import 'package:echo_stream/widgets/post_headline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentListTile extends StatefulWidget {
  const CommentListTile({super.key, required this.commentID});
  final String commentID;

  @override
  State<CommentListTile> createState() => _CommentListTileState();
}

class _CommentListTileState extends State<CommentListTile> {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser!;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _commentSnapshot;

  @override
  void initState() {
    super.initState();
    _commentSnapshot =
        _firestore.collection('comments').doc(widget.commentID).snapshots();
  }

  void _toggleCommentLike(final bool hasAlreadyLiked) async {
    FieldValue action;
    if (hasAlreadyLiked) {
      action = FieldValue.arrayRemove([_currentUser.uid]);
    } else {
      action = FieldValue.arrayUnion([_currentUser.uid]);
    }

    await _firestore.collection('comments').doc(widget.commentID).update({
      'commentLikes': action,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _commentSnapshot,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        if (snapshot.data == null || snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        final commentData = snapshot.data!;
        Comment comment = Comment.fromJson(
          commentData.data()!,
          id: commentData.id,
        );

        final hasAlreadyLiked = comment.likes.contains(_currentUser.uid);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostHeadline(userID: commentData['commentorID']),
            Text(commentData['commentContent']),
            const SizedBox(height: 16.0),
            LabelledIconButton(
              onPressed: () async {
                _toggleCommentLike(hasAlreadyLiked);
              },
              label: '${commentData['commentLikes'].length}',
              icon: Icon(
                hasAlreadyLiked ? Icons.favorite : Icons.favorite_outline,
              ),
            ),
          ],
        );
      },
    );
  }
}
