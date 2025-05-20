import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_stream/models/user.dart';
import 'package:echo_stream/repositories/user_repository.dart';
import 'package:echo_stream/screens/tabs/user_list_tab.dart';
import 'package:echo_stream/screens/tabs/user_posts_tab.dart';
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
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _profileUser;

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(length: 3, vsync: this);
    _profileUser = UserRepository().getUserSnapshot(widget.userID);
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PostHeadline(userID: user.id),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                user.bio.isEmpty ? 'No bio' : user.bio,
                style: TextStyle(fontSize: 16.0),
              ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TabBarView(
                  controller: _tabBarController,
                  children: [
                    UserPostsTab(userID: user.id),
                    UserListTab(userIDs: user.followers),
                    UserListTab(userIDs: user.followings),
                  ],
                ),
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
