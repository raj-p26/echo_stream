import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/models/post.dart';
import 'package:echo_stream/repositories/post_repository.dart';
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

  final void Function()? onPressed;
  final void Function()? onDeleted;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _postRepository = PostRepository();
  final _currentUser = FirebaseAuth.instance.currentUser!;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _postStream;
  late TextEditingController _editPostContentController;

  Future<void> _toggleLike(final String postID, bool likedAlready) async {
    if (likedAlready) {
      _postRepository.unlikePost(postID: postID, userID: _currentUser.uid);
    } else {
      _postRepository.likePost(postID: postID, userID: _currentUser.uid);
    }
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

    await _postRepository.updatePost(
      postID: widget.postID,
      updatedContent: updatedContent,
    );
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

  void _confirmDeletePost(final Post post) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete?'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _postRepository.deletePost(post: post);
                if (widget.onDeleted != null) widget.onDeleted!();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _postStream = _postRepository.getPost(widget.postID);
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
          onTap: widget.onPressed,
          child: Card.outlined(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostHeadline(userID: postData.postCreatorID),
                  Text(postData.postContent, style: TextStyle(fontSize: 20.0)),
                  if (postData.createdAt.compareTo(postData.updatedAt) < 0)
                    const Text('(edited)'),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      LabelledIconButton(
                        onPressed: () async {
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
