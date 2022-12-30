import '../classes/Post.dart';
import '../classes/recipe.dart';
import '../classes/user.dart';

class DummyData{

  Recipe recipe1 = Recipe(title: 'salad', ingredients: ['lettuce', 'dressing'], description: 'a delicious salad with fruits, cinammon and pineapples', tags: ['healthy', 'yummi'], nutrition: ['proteins','carbs']);
  Recipe recipe2 = Recipe(title: 'burger', ingredients: ['lettuce', 'meat','buns'], description: 'a healthy burger, nuff'' said', tags: ['delicious', 'yummi'], nutrition: ['proteins','carbs']);

  User user1 = User(username: 'Fred1214', name: 'Frederick', rights: true,  mailAddress: 'fred1214@gmail.com');
  User user2 = User(username: 'Tommy1156', name: 'Thomas', rights: true, mailAddress: 'thomasMueller@outlook.com');


  List<Post> get returnData {
    Post post1 = Post(
        recipe: recipe1, creator: user1, creationDate: DateTime.now());
    Post post2 = Post(
        recipe: recipe2, creator: user2, creationDate: DateTime.now());

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