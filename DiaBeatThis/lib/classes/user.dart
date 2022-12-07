import 'dart:ffi';
import 'Post.dart';

class User {
  User(
      {required this.username,
      required this.name,
      required this.rights,
      required this.follower,
      required this.following,
      required this.mailAddress,
      required this.favorites,
      required this.posts});

  String username;
  String name;
  Bool rights;
  List<User> follower;
  List<User> following;
  String mailAddress;
  List<Post> favorites;
  List<Post> posts;
}
