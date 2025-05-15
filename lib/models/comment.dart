class Comment {
  late String id, content, commentorID;
  late DateTime commentedAt, updatedAt;
  late List<String> likes;

  Comment.fromJson(Map<String, dynamic> data, {required this.id}) {
    content = data['commentContent'];
    likes = List<String>.from(data['commentLikes']);
    commentorID = data['commentorID'];
    commentedAt = data['commentedAt'].toDate();
    updatedAt = data['updatedAt'].toDate();
  }

  @override
  String toString() {
    return 'Comment {\n'
        '  id: $id,\n'
        '  body: $content,\n'
        '  likes: $likes,\n'
        '  commentorID: $commentorID,\n'
        '  commentedAt: $commentedAt,\n'
        '  updatedAt: $updatedAt,\n'
        '}';
  }
}
