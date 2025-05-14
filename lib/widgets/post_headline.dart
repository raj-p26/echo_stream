import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostHeadline extends StatefulWidget {
  const PostHeadline({super.key, required this.userID});

  final String userID;

  @override
  State<PostHeadline> createState() => _PostHeadlineState();
}

class _PostHeadlineState extends State<PostHeadline> {
  final _firestore = FirebaseFirestore.instance;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userInfo;

  @override
  void initState() {
    super.initState();
    _userInfo = _firestore.collection('users').doc(widget.userID).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userInfo,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Text(snapshot.error.toString());
        }

        final userInfo = snapshot.data!;

        return Row(
          children: [
            Icon(Icons.person_outline),
            SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userInfo['fullName'], style: TextStyle(fontSize: 16.0)),
                Text(
                  '@${userInfo['username']}',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
