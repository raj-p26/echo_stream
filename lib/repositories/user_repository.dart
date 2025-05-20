import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/config.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef QueryStream = Stream<QuerySnapshot<Map<String, dynamic>>>;
typedef DocSnapshot = DocumentSnapshot<Map<String, dynamic>>;

class UserRepository {
  static final currentUser = Config.firebaseAuth.currentUser;
  final _usersCollection = Config.firestore.collection('users');
  static const _randomUserCount = 10;

  static Stream<User?> get userAuthStream {
    return Config.firebaseAuth.authStateChanges();
  }

  QueryStream get randomUsers {
    return _usersCollection.limit(_randomUserCount).snapshots();
  }

  Future<DocSnapshot> getUserDocByID(String userID) {
    return _usersCollection.doc(userID).get();
  }

  Stream<DocSnapshot> getUserSnapshot(String userID) {
    return _usersCollection.doc(userID).snapshots();
  }

  Future<bool> usernameExists(String username) async {
    final res =
        await _usersCollection
            .where('username', isEqualTo: username)
            .count()
            .get();
    if (res.count != null) return res.count! > 0;

    return false;
  }

  Future<void> createUser(
    String userID, {
    required String fullName,
    required String email,
  }) async {
    await _usersCollection.doc(userID).set({
      'fullName': fullName,
      'email': email,
      'followers': [],
      'followings': [],
    });
  }

  Future<void> updateUser(String userID, Map<String, dynamic> data) async {
    await _usersCollection.doc(userID).update(data);
  }

  QueryStream getUserByUsername(String username) {
    return _usersCollection.where('username', isEqualTo: username).snapshots();
  }

  Future<void> followUser({
    required String userID,
    required String followerID,
  }) async {
    await _usersCollection.doc(userID).update({
      'followers': FieldValue.arrayUnion([followerID]),
    });
    await _usersCollection.doc(followerID).update({
      'followings': FieldValue.arrayUnion([userID]),
    });
  }

  Future<void> unfollowUser({
    required String userID,
    required String followerID,
  }) async {
    await _usersCollection.doc(userID).update({
      'followers': FieldValue.arrayRemove([followerID]),
    });
    await _usersCollection.doc(followerID).update({
      'followings': FieldValue.arrayRemove([userID]),
    });
  }
}
