import 'package:diabeatthis/data/dummy_data.dart';
import 'package:diabeatthis/screens/createRecipe_screen.dart';
import 'package:diabeatthis/screens/post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> _signout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          FloatingActionButton.extended(
              label: FirebaseAuth.instance.currentUser!.isAnonymous
                  ? const Text("Login")
                  : const Text("Logout"), // <-- Text
              backgroundColor: Colors.black,
              icon: Icon(
                  FirebaseAuth.instance.currentUser!.isAnonymous
                      ? Icons.login
                      : Icons.logout,
                  size: 24.0),
              onPressed: () => _signout())
        ],
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.forward) {
            if (!isvisible) {
              setState(() => isvisible = true);
            }
          } else if (notification.direction == ScrollDirection.reverse) {
            if (isvisible) {
              setState(() => isvisible = false);
            }
          } else if (notification.direction == ScrollDirection.reverse) {
            if (isvisible) {
              setState(() => isvisible = false);
            }
          }
          return true;
        },
        child: SafeArea(
          child: ListView.separated(
            itemBuilder: (context, index) => _buildRecipeTile(index),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: posts?.length ?? 0,
          ),
        ),
      ),
      floatingActionButton: isvisible
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateRecipeScreen()));
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
          style: const TextStyle(fontSize: 22),
        ),
        subtitle: Text(
          '${post.recipe.description} \nby User ${post.creator.username}',
          style: const TextStyle(fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_outlined),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) {
              return PostScreen(post: post);
            }),
          );
        });
  }
}
