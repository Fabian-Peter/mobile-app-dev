import 'package:diabeatthis/data/dummy_data.dart';
import 'package:diabeatthis/screens/createRecipe_screen.dart';
import 'package:diabeatthis/screens/post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../classes/Post.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isvisible = false;
  List<Post>? posts = DummyData().returnData;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.forward) {
            if (!isvisible) setState(() => isvisible = true);
          } else if (notification.direction == ScrollDirection.reverse)
            if (isvisible) setState(() => isvisible = false);
          return true;
        },
        child: SafeArea(
          child: ListView.separated(
            itemBuilder: (context, index) => _buildRecipeTile(index),
            separatorBuilder: (_, __) => Divider(),
            itemCount: posts?.length ?? 0,
          ),
        ),
      ),
      floatingActionButton: isvisible
          ? FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateRecipeScreen()));
        },

      )
          : null,
    );
  }


  Widget _buildRecipeTile(int index) {
    final Post post = posts![index];
    return ListTile(
        title: Text(
          post.recipe.title,
          style: TextStyle(fontSize: 22),
        ),
        subtitle: Text(
          '${post.recipe.description} \nby User ${post.creator.username}',
          style: TextStyle(fontSize: 16),

        ),
        trailing: Icon(Icons.arrow_forward_ios_outlined),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) {
              return PostScreen(post: post);
            }),
          );
        });
  }


}
