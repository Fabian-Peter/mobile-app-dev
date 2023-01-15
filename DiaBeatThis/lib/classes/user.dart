import 'package:image_picker/image_picker.dart';

import 'Post.dart';

class User {
  User(
      {required this.uid,
      required this.username,
      required this.name,
      this.profilePicture,
      this.follower,
      this.following,
      required this.mailAddress,
      this.favorites,
      this.posts});

  String uid;
  String username;
  String name;
  XFile? profilePicture;
  List<User>? follower;
  List<User>? following;
  String mailAddress;
  List<Post>? favorites;
  List<Post>? posts;
}
