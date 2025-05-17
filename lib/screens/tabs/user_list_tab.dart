import 'package:echo_stream/widgets/post_headline.dart';
import 'package:flutter/material.dart';

class UserListTab extends StatefulWidget {
  const UserListTab({super.key, required this.userIDs});
  final List<String> userIDs;

  @override
  State<UserListTab> createState() => _UserListTabState();
}

class _UserListTabState extends State<UserListTab> {
  @override
  Widget build(BuildContext context) {
    final userIDs = widget.userIDs;

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
