class Post {
  late String id, postContent, postCreatorID;
  late List<String> likes, comments;
  late DateTime createdAt, updatedAt;

  Post.fromJson(Map<String, dynamic> data, {required this.id}) {
    postContent = data['postContent'];
    postCreatorID = data['postCreatorID'];
    likes = List<String>.from(data['likes']);
    comments = List<String>.from(data['comments']);
    createdAt = data['createdAt'].toDate();
    updatedAt = data['updatedAt'].toDate();
  }

  @override
  String toString() {
    return 'Post {'
        '    id: $id,\n'
        '    postContent: $postContent,\n'
        '    postCreatorID: $postCreatorID,\n'
        '    likes: $likes,\n'
        '    createdAt: $createdAt\n'
        '}';
  }
}
