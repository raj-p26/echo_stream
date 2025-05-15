import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/models/post.dart';
import 'package:echo_stream/widgets/labelled_icon_button.dart';
import 'package:echo_stream/widgets/post_headline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.postID,
    this.onPressed,
    this.onDeleted,
  });

  final String postID;

  final void Function(String postID)? onPressed;
  final void Function()? onDeleted;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _postStream;
  late TextEditingController _editPostContentController;

  bool _isSubmitting = false;

  Future<void> _toggleLike(final String postID, bool likedAlready) async {
    setState(() {
      _isSubmitting = true;
    });
    if (likedAlready) {
      await _firestore.collection('posts').doc(postID).update({
        'likes': FieldValue.arrayRemove([_currentUser.uid]),
      });
    } else {
      await _firestore.collection('posts').doc(postID).update({
        'likes': FieldValue.arrayUnion([_currentUser.uid]),
      });
    }
    setState(() {
      _isSubmitting = false;
    });
  }

  void _updatePost(
    final String previousContent,
    final String updatedContent,
  ) async {
    if (previousContent == updatedContent) {
      Navigator.pop(context);
      return;
    }

    if (updatedContent == '') {
      _showSnackbar('Post body cannot be empty');
      Navigator.pop(context);
      return;
    }

    await _firestore.collection('posts').doc(widget.postID).update({
      'postContent': updatedContent,
      'updatedAt': Timestamp.now(),
    });
    if (context.mounted) Navigator.pop(context);
  }

  void _showSnackbar(final String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showUpdatePostSheet(final String postContent) {
    _editPostContentController.text = postContent;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 30.0),
              AppBar(
                title: const Text('Update your post'),
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerLow,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _editPostContentController,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      maxLines: null,
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        const Spacer(),
                        FilledButton(
                          onPressed: () {
                            _updatePost(
                              postContent,
                              _editPostContentController.text.trim(),
                            );
                          },
                          child: Text('Update'),
                        ),
                      ],
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

  Future<void> _deletePost(final Post post) async {
    await _firestore.collection('posts').doc(post.id).delete();
    for (String commentID in post.comments) {
      await _firestore.collection('comments').doc(commentID).delete();
    }
  }

  void _confirmDeletePost(final Post post) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete?'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _deletePost(post);
                if (widget.onDeleted != null) widget.onDeleted!();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _postStream = _firestore.collection('posts').doc(widget.postID).snapshots();
    _editPostContentController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _postStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.data == null || snapshot.data!.data() == null) {
          return Text('No Data');
        }

        final postData = Post.fromJson(
          snapshot.data!.data()!,
          id: snapshot.data!.id,
        );
        final likedAlready = postData.likes.contains(_currentUser.uid);
        final likesCount = postData.likes.length;
        final isPostCreator = _currentUser.uid == postData.postCreatorID;

        return InkWell(
          onTap:
              widget.onPressed == null
                  ? null
                  : () {
                    widget.onPressed!(postData.id);
                  },
          child: Card.outlined(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                left: 20.0,
                right: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostHeadline(userID: postData.postCreatorID),
                  const SizedBox(height: 10.0),
                  Text(postData.postContent, style: TextStyle(fontSize: 20.0)),
                  if (postData.createdAt.compareTo(postData.updatedAt) < 0)
                    const Text('(edited)'),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      LabelledIconButton(
                        onPressed:
                            _isSubmitting
                                ? null
                                : () async {
                                  await _toggleLike(postData.id, likedAlready);
                                },
                        icon: Icon(
                          likedAlready
                              ? Icons.favorite
                              : Icons.favorite_outline,
                        ),
                        label: '$likesCount',
                      ),
                      LabelledIconButton(
                        label: '${postData.comments.length}',
                        icon: Icon(
                          Icons.comment_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      if (isPostCreator)
                        LabelledIconButton(
                          onPressed: () {
                            _showUpdatePostSheet(postData.postContent);
                          },
                          color: Theme.of(context).colorScheme.tertiary,
                          icon: Icon(Icons.edit_outlined),
                        ),
                      if (isPostCreator)
                        LabelledIconButton(
                          onPressed: () {
                            _confirmDeletePost(postData);
                          },
                          color: Theme.of(context).colorScheme.error,
                          icon: Icon(Icons.delete_outline),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _editPostContentController.dispose();
  }
}
