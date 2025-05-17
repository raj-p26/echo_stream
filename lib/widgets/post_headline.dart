import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/models/user.dart';
import 'package:echo_stream/screens/see_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostHeadline extends StatefulWidget {
  const PostHeadline({super.key, required this.userID});

  final String userID;

  @override
  State<PostHeadline> createState() => _PostHeadlineState();
}

class _PostHeadlineState extends State<PostHeadline> {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser!;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userInfo;

  @override
  void initState() {
    super.initState();
    _userInfo = _firestore.collection('users').doc(widget.userID).snapshots();
  }

  Future<void> _followUser({required final bool isFollowing}) async {
    if (isFollowing) {
      await _firestore.collection('users').doc(widget.userID).update({
        'followers': FieldValue.arrayRemove([_currentUser.uid]),
      });
      await _firestore.collection('users').doc(_currentUser.uid).update({
        'followings': FieldValue.arrayRemove([widget.userID]),
      });
    } else {
      await _firestore.collection('users').doc(widget.userID).update({
        'followers': FieldValue.arrayUnion([_currentUser.uid]),
      });
      await _firestore.collection('users').doc(_currentUser.uid).update({
        'followings': FieldValue.arrayUnion([widget.userID]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _userInfo,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Text(snapshot.error.toString());
        }

        final userInfo = EchoStreamUser.fromJson(
          snapshot.data!.data()!,
          id: snapshot.data!.id,
        );
        final isFollowing = userInfo.followers.contains(_currentUser.uid);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (routeCtx) {
                    return SeeProfile(userID: userInfo.id);
                  },
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.person_outline),
                SizedBox(width: 10.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(userInfo.fullName, style: TextStyle(fontSize: 18.0)),
                    const SizedBox(width: 6.0),
                    Text(
                      '@${userInfo.username}',
                      style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
                const Spacer(),
                if (widget.userID != _currentUser.uid)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _followUser(isFollowing: isFollowing);
                    },
                    label: Text(isFollowing ? 'Following' : 'Follow'),
                    icon: Icon(isFollowing ? Icons.check : Icons.add),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
