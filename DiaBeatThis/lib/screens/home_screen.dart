import 'package:diabeatthis/screens/post_screen.dart';
import 'package:flutter/material.dart';

import '../classes/Post.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post>? posts;



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
      body: SafeArea(
        child: ListView.separated(
          itemBuilder: (context, index) => _buildRecipeTile(index),
          separatorBuilder: (_, __) => Divider(),
          itemCount: posts?.length ?? 0,
        ),
      ),
    );
  }


  Widget _buildRecipeTile(int index) {
    final Post post = posts![index];
    return ListTile(
        title: Text(
          '${index + 1}. ${post.recipe.title}',
          style: TextStyle(fontSize: 17),
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
