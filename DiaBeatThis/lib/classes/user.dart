import 'dart:ffi';
import 'Post.dart';

class User {
  User(
      {required this.username,
      required this.name,
      required this.rights,
      this.follower,
      this.following,
      required this.mailAddress,
      this.favorites,
      this.posts});

  String username;
  String name;
  bool rights;
  List<User>? follower;
  List<User>? following;
  String mailAddress;
  List<Post>? favorites;
  List<Post>? posts;
}
