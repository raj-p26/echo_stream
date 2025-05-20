import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/config.dart';
import 'package:echo_stream/models/post.dart';

typedef QueryStream = Stream<QuerySnapshot<Map<String, dynamic>>>;
typedef DocSnapshot = DocumentSnapshot<Map<String, dynamic>>;

class PostRepository {
  final _postsCollection = Config.firestore.collection('posts');
  final _commentCollection = Config.firestore.collection('comments');

  Stream<DocSnapshot> getPost(String postID) {
    return _postsCollection.doc(postID).snapshots();
  }

  Future<void> createPost({
    required String creatorID,
    required String content,
  }) async {
    final currentTimestamp = Timestamp.now();
    await _postsCollection.add({
      'postCreatorID': creatorID,
      'postContent': content,
      'likes': [],
      'comments': [],
      'createdAt': currentTimestamp,
      'updatedAt': currentTimestamp,
    });
  }

  Future<void> likePost({
    required String postID,
    required String userID,
  }) async {
    await _postsCollection.doc(postID).update({
      'likes': FieldValue.arrayUnion([userID]),
    });
  }

  Future<void> unlikePost({
    required String postID,
    required String userID,
  }) async {
    await _postsCollection.doc(postID).update({
      'likes': FieldValue.arrayRemove([userID]),
    });
  }

  Future<void> updatePost({
    required String postID,
    required String updatedContent,
  }) async {
    await _postsCollection.doc(postID).update({
      'postContent': updatedContent,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deletePost({required Post post}) async {
    for (final commentID in post.comments) {
      await _commentCollection.doc(commentID).delete();
    }
    await _postsCollection.doc(post.id).delete();
  }

  Future<void> addComment({
    required String commentID,
    required String postID,
  }) async {
    await _postsCollection.doc(postID).update({
      'comments': FieldValue.arrayUnion([commentID]),
    });
  }

  Future<void> removeComment({
    required String postID,
    required String commentID,
  }) async {
    await _postsCollection.doc(postID).update({
      'comments': FieldValue.arrayRemove([commentID]),
    });
  }
}
