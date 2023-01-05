import 'package:image_picker/image_picker.dart';

class Recipe {
  Recipe(
      {required this.title,
      required this.ingredients,
      required this.description,
      required  this.directions,
      this.tags,
      this.nutrition,
      this.pictureUrl});

  List<String> directions;
  String title;
  List<String> ingredients;
  String description;
  List<String>? tags;
  List<String>? nutrition;
  XFile? pictureUrl;
}
