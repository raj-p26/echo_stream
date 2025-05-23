import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/models/comment.dart';
import 'package:echo_stream/repositories/comment_repository.dart';
import 'package:echo_stream/repositories/user_repository.dart';
import 'package:echo_stream/widgets/labelled_icon_button.dart';
import 'package:echo_stream/widgets/post_headline.dart';
import 'package:flutter/material.dart';

class CommentListTile extends StatefulWidget {
  const CommentListTile({super.key, required this.commentID, this.onDelete});
  final String commentID;

  final void Function()? onDelete;

  @override
  State<CommentListTile> createState() => _CommentListTileState();
}

class _CommentListTileState extends State<CommentListTile> {
  final _commentRepository = CommentRepository();
  final _currentUser = UserRepository.currentUser!;
  final _commentEditingController = TextEditingController();
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _commentSnapshot;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _commentSnapshot = _commentRepository.getPost(widget.commentID);
  }

  void _updateComment({
    required String previousContent,
    required String newContent,
  }) async {
    if (previousContent == newContent) return;

    _commentRepository.updateComment(
      commentID: widget.commentID,
      newContent: newContent,
    );

    if (context.mounted) Navigator.pop(context);
  }

  void _updateCommentBottomSheet(final String content) {
    _commentEditingController.text = content;

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
                title: const Text('Edit your comment'),
                backgroundColor: theme.colorScheme.surfaceContainerLow,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _commentEditingController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
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
                      onPressed: () {
                        _updateComment(
                          previousContent: content,
                          newContent: _commentEditingController.text,
                        );
                      },
                      child: const Text('Update'),
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

  void _deleteComment(Comment comment) async {
    setState(() => _isLoading = true);
    if (widget.onDelete != null) widget.onDelete!();
    await _commentRepository.deleteComment(comment.id);
    setState(() => _isLoading = false);
  }

  void _confirmDeleteComment(final Comment comment) {
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
              onPressed: () {
                _deleteComment(comment);
                Navigator.pop(ctx);
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

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
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
            PostHeadline(userID: comment.commentorID),
            Text(comment.content),
            if (comment.commentedAt.compareTo(comment.updatedAt) < 0)
              const Text('(edited)'),
            Row(
              children: [
                LabelledIconButton(
                  onPressed: () async {
                    _commentRepository.toggleLikeComment(
                      commentID: comment.id,
                      userID: _currentUser.uid,
                      isLikedAlready: hasAlreadyLiked,
                    );
                  },
                  label: '${comment.likes.length}',
                  icon: Icon(
                    hasAlreadyLiked ? Icons.favorite : Icons.favorite_outline,
                  ),
                ),
                SizedBox(width: 10.0),
                if (comment.commentorID == _currentUser.uid)
                  LabelledIconButton(
                    onPressed: () {
                      _updateCommentBottomSheet(comment.content);
                    },
                    color: Theme.of(context).colorScheme.tertiary,
                    icon: Icon(Icons.edit_outlined),
                  ),
                if (comment.commentorID == _currentUser.uid)
                  LabelledIconButton(
                    onPressed: () {
                      _confirmDeleteComment(comment);
                    },
                    color: Theme.of(context).colorScheme.error,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _commentEditingController.dispose();
  }
}
