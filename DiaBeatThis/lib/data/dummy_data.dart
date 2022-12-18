import '../classes/Post.dart';
import '../classes/recipe.dart';
import '../classes/user.dart';

class DummyData {
  Recipe recipe1 = Recipe(
      title: 'Greek salad with peppers and radishes',
      ingredients: [
        '1 head of lettuce',
        '50ml dressing of your choice (preferably low carb)',
        '2 tomatoes',
        '1 pepper',
        '100g feta cheese',
        '5 radishes'
      ],
      description:
          'A delicious salad with greek cheese, peppers and radishes. Very easy to make with only few ingredients.',
      directions: [
        'Wash all vegetables with water.',
        'Cut the lettuce head in half, hold and finely slice the wedges vertically for long strips of lettuce.',
        'Dice both tomatoes.',
        'Dice the pepper',
        'Cut the radishes in fine slices.',
        'Combine all vegetables in a big bowl.',
        'Crumble the feta over the bowl',
        'Add the dressing as well as salt & pepper',
        'Mix all well together.'
      ],
      tags: ['vegetarian', 'gluten free'],
      nutrition: ['10g proteins', '5g fat', '10g carbs']);

  Recipe recipe2 = Recipe(
      title: 'burger',
      ingredients: ['lettuce', 'meat', 'buns'],
      description: 'a healthy burger, nuff' ' said',
      directions: ['do this and that'],
      tags: ['meat', 'yummi'],
      nutrition: ['proteins', 'carbs']);

  User user1 = User(
      username: 'Fred1214',
      name: 'Frederick',
      rights: true,
      mailAddress: 'fred1214@gmail.com');
  User user2 = User(
      username: 'Tommy1156',
      name: 'Thomas',
      rights: true,
      mailAddress: 'thomasMueller@outlook.com');

  List<Post> get returnData {
    Post post1 =
        Post(recipe: recipe1, creator: user1, creationDate: DateTime.now());
    Post post2 =
        Post(recipe: recipe2, creator: user2, creationDate: DateTime.now());

    List<Post> posts = <Post>[];
    posts.add(post1);
    posts.add(post2);
    posts.add(post1);
    posts.add(post2);
    posts.add(post1);
    posts.add(post2);
    posts.add(post1);
    posts.add(post2);
    posts.add(post1);
    posts.add(post2);
    posts.add(post1);
    posts.add(post2);
    posts.add(post1);
    posts.add(post2);
    posts.add(post1);
    posts.add(post2);
    posts.add(post1);
    posts.add(post2);

    return posts;
  }
}
