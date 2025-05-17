import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/models/user.dart';
import 'package:echo_stream/screens/tabs/user_list_tab.dart';
import 'package:echo_stream/widgets/post_headline.dart';
import 'package:flutter/material.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.userID});
  final String userID;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with TickerProviderStateMixin {
  late TabController _tabBarController;
  final _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _profileUser;

  @override
  void initState() {
    super.initState();
    _profileUser =
        _firestore.collection('users').doc(widget.userID).snapshots();
    _tabBarController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _profileUser,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No data'));
        }

        final user = EchoStreamUser.fromJson(
          snapshot.data!.data()!,
          id: snapshot.data!.id,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostHeadline(userID: user.id),
            Text(
              user.bio.isEmpty ? 'No bio' : user.bio,
              style: TextStyle(fontSize: 16.0),
            ),
            TabBar(
              controller: _tabBarController,
              tabs: [
                Tab(child: const Text('Posts')),
                Tab(child: Text('${user.followers.length} Followers')),
                Tab(child: Text('${user.followings.length} Followings')),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabBarController,
                children: [
                  const Center(child: Text('Posts')),
                  UserListTab(userIDs: user.followers),
                  UserListTab(userIDs: user.followings),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabBarController.dispose();
  }
}
