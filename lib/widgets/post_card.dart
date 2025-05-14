import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/widgets/post_headline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.postID});

  final String postID;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _postStream;

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

  @override
  void initState() {
    super.initState();
    _postStream = _firestore.collection('posts').doc(widget.postID).snapshots();
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

        final postData = snapshot.data!;
        final likedAlready = postData['likes'].contains(_currentUser.uid);
        final likesCount = postData['likes'].length;

        return Card.outlined(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostHeadline(userID: postData['postCreatorID']),
                const SizedBox(height: 10.0),
                Text(postData['postContent'], style: TextStyle(fontSize: 20.0)),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed:
                              _isSubmitting
                                  ? null
                                  : () async {
                                    await _toggleLike(
                                      postData.id,
                                      likedAlready,
                                    );
                                  },
                          icon: Icon(
                            likedAlready
                                ? Icons.favorite
                                : Icons.favorite_outline,
                          ),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Text('$likesCount'),
                      ],
                    ),
                    IconButton(onPressed: () {}, icon: Icon(Icons.comment)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
