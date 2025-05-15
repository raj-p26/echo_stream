import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/widgets/comments_list.dart';
import 'package:echo_stream/widgets/post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SeePost extends StatefulWidget {
  const SeePost({super.key, required this.postID});
  final String postID;

  @override
  State<SeePost> createState() => _SeePostState();
}

class _SeePostState extends State<SeePost> {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  void _createComment() async {
    setState(() {
      _isSubmitting = true;
    });
    final commentContent = _commentController.text.trim();
    if (commentContent.isEmpty) {
      _showSnackbar('Comment cannot be empty');
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    _commentController.clear();
    var currentTimestamp = Timestamp.now();

    final comment = await _firestore.collection('comments').add({
      'commentedAt': currentTimestamp,
      'commentContent': commentContent,
      'commentorID': _currentUser.uid,
      'commentLikes': [],
      'updatedAt': currentTimestamp,
    });

    await _firestore.collection('posts').doc(widget.postID).update({
      'comments': FieldValue.arrayUnion([comment.id]),
    });

    setState(() {
      _isSubmitting = false;
    });
  }

  void _showSnackbar(final String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          PostCard(
            postID: widget.postID,
            onDeleted: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10.0),
          Expanded(child: CommentsList(postID: widget.postID)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        label: const Text('Post your reply'),
                      ),
                      maxLines: null,
                    ),
                  ),
                  SizedBox(width: 20),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _createComment,
                    child: const Text('Post'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
