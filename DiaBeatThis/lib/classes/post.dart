import 'package:diabeatthis/classes/recipe.dart';
import 'package:diabeatthis/classes/user.dart';

class Post {
  Post(
      {required this.recipe,
      required this.creator,
      this.comments,
      this.likes,
      this.reactions,
      required this.creationDate});

  Recipe recipe;
  User creator;
  List<String>? comments;
  List<User>? likes;
  Map<String, User>? reactions;
  DateTime creationDate;
}
