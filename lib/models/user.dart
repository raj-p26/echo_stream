class EchoStreamUser {
  late String id, fullName, username, email;
  late List<String> followers, followings;

  EchoStreamUser.fromJson(Map<String, dynamic> data, {required this.id}) {
    fullName = data['fullName'];
    username = data['username'];
    email = data['email'];
    followers = List<String>.from(data['followers']);
    followings = List<String>.from(data['followings']);
  }

  @override
  String toString() {
    return 'User {\n'
        '  id: $id,\n'
        '  fullName: $fullName,\n'
        '  username: @$username,\n'
        '  email: $fullName,\n'
        '  followers: $fullName,\n'
        '  followings: $fullName\n'
        '}';
  }
}
