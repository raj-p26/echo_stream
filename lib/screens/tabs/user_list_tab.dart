import 'package:echo_stream/widgets/post_headline.dart';
import 'package:flutter/material.dart';

class UserListTab extends StatelessWidget {
  const UserListTab({super.key, required this.userIDs});
  final List<String> userIDs;

  @override
  Widget build(BuildContext context) {
    if (userIDs.isEmpty) return const Center(child: Text('No data'));

    return ListView.builder(
      itemCount: userIDs.length,
      itemBuilder: (ctx, idx) {
        final userID = userIDs[idx];
        return PostHeadline(key: Key(userID), userID: userID);
      },
    );
  }
}
