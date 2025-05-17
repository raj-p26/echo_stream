import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/screens/see_post.dart';
import 'package:echo_stream/widgets/post_card.dart';
import 'package:flutter/material.dart';

class UserPostsTab extends StatefulWidget {
  const UserPostsTab({super.key, required this.userID});
  final String userID;

  @override
  State<UserPostsTab> createState() => _UserPostsTabState();
}

class _UserPostsTabState extends State<UserPostsTab> {
  final _firestore = FirebaseFirestore.instance;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _userPostsStream;

  @override
  void initState() {
    super.initState();
    _userPostsStream =
        _firestore
            .collection('posts')
            .where('postCreatorID', isEqualTo: widget.userID)
            .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _userPostsStream,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final data = snapshot.data;

        if (data == null) {
          return const Center(child: Text('No data'));
        }

        return ListView.builder(
          itemCount: data.docs.length,
          itemBuilder: (listCtx, idx) {
            return PostCard(
              key: Key(data.docs[idx].id),
              postID: data.docs[idx].id,
              onPressed: (postID) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builderContext) => SeePost(postID: postID),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
