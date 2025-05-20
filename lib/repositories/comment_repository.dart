import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/config.dart';
import 'package:echo_stream/repositories/post_repository.dart';

typedef QueryStream = Stream<QuerySnapshot<Map<String, dynamic>>>;
typedef DocSnapshot = DocumentSnapshot<Map<String, dynamic>>;

class CommentRepository {
  final _commentsCollection = Config.firestore.collection('comments');
  final _postRepository = PostRepository();

  Stream<DocSnapshot> getPost(String commentID) {
    return _commentsCollection.doc(commentID).snapshots();
  }

  Future<void> addComment({
    required String content,
    required String userID,
    required String postID,
  }) async {
    final currentTimestamp = Timestamp.now();

    final comment = await _commentsCollection.add({
      'commentedAt': currentTimestamp,
      'commentContent': content,
      'commentorID': userID,
      'commentLikes': [],
      'updatedAt': currentTimestamp,
    });

    await _postRepository.addComment(postID: postID, commentID: comment.id);
  }

  Future<void> updateComment({
    required String commentID,
    required String newContent,
  }) async {
    if (newContent.trim().isEmpty) return;
    await _commentsCollection.doc(commentID).update({
      'commentContent': newContent,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteComment(String commentID) async {
    await _commentsCollection.doc(commentID).delete();
  }

  Future<void> toggleLikeComment({
    required String commentID,
    required String userID,
    required bool isLikedAlready,
  }) async {
    final FieldValue action;
    if (isLikedAlready) {
      action = FieldValue.arrayRemove([userID]);
    } else {
      action = FieldValue.arrayUnion([userID]);
    }

    await _commentsCollection.doc(commentID).update({'commentLikes': action});
  }
}
