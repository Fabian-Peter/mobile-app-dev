import 'package:diabeatthis/screens/settings_screen.dart';
import 'package:diabeatthis/utils/constants.dart';
import 'package:diabeatthis/screens/post_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:diabeatthis/data/dummy_data.dart';

import '../classes/Post.dart';
import '../classes/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //final User profile = DummyData().user1;
  final List<Post> posts = DummyData().returnData;
  IconData _favIconOutlined = Icons.favorite_outline;
  String? query = FirebaseAuth.instance.currentUser?.uid.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DiaBeatThis!', style: DIABEATTHIS_LOGO),
        //actions: <Widget>[_buildSettingsIcon(context)]
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileIcon(context),
                  _buildUsername(context, snapshot),
                  _buildEditIcon(context),
                  _buildProfile(context),
                  _buildListOfPosts(context)
                ],
              ))),
    );
  }

  Widget _buildSettingsIcon(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(PROFILE_ICON_BAR_SIZE / 2),
      child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
              icon: const Icon(Icons.settings, color: COLOR_WHITE),
              onPressed: () {
                //TODO: open settings menu
              })),
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(PROFILE_ICON_BAR_SIZE / 2),
      child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: InkWell(
              child: Image.asset(
                //TODO: if guest, then show anonymous profile icon
                'assets/images/Profile.png', //TODO: replace with user image
                height: PROFILE_ICON_BAR_SIZE,
                width: PROFILE_ICON_BAR_SIZE,
              ),
              onTap: () {
                //TODO: open profile instead
              })),
    );
  }

  Widget _buildUsername(BuildContext context, DataSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Text(
          snapshot.child('currentUser').value.toString(),
          style: HOME_POST_CREATOR,
        ),
      ),
    );
  }

  Widget _buildEditIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        FloatingActionButton.extended(
          heroTag: "editButton",
          backgroundColor: COLOR_INDIGO,
          label: const Text("Edit"),
          icon: const Icon(Icons.edit, color: COLOR_WHITE),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) {
                return SettingsScreen();
              }),
            );
          },
        )
      ]),
    );
  }

  Widget _buildProfile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      child: Row(
        children: [
          _buildNumberOfPosts(context),
          //_buildFollower(context),
          //_buildFollowing(context)
        ],
      ),
    );
  }

  Widget _buildNumberOfPosts(BuildContext context) {
    //Todo return len of list and create new screen with Posts list
    return Expanded(
      child: Column(children: [
        Text(posts.length.toString(), style: TEXT_BOLD),
        const SizedBox(height: 4),
        const Text("Posts", style: TEXT_PLAIN)
      ]),
    );
  }

  Widget _buildFollower(BuildContext context) {
    //Todo return len of list and create new screen with follower list
    return Expanded(
      child: Column(children: [
        Text(500.toString(), style: TEXT_BOLD),
        const SizedBox(height: 4),
        const Text("Follower", style: TEXT_PLAIN)
      ]),
    );
  }

  Widget _buildFollowing(BuildContext context) {
    //Todo return len of list and create new screen with following list
    return Expanded(
      child: Column(children: [
        Text(250.toString(), style: TEXT_BOLD),
        const SizedBox(height: 4),
        const Text("Following", style: TEXT_PLAIN)
      ]),
    );
  }

  Widget _buildListOfPosts(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        primary: false,
        padding: const EdgeInsets.all(5),
        itemCount: posts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 200 / 200),
        itemBuilder: (context, index) {
          return _buildPosts(context, index);
        });
  }

  Widget _buildPosts(BuildContext context, int index) {
    final Post post = posts[index];
    return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 7,
        ),
        child: InkWell(
          child: Container(
            decoration: BoxDecoration(
              color: COLOR_WHITE,
              border: Border.all(width: 3, color: COLOR_INDIGO_LIGHT),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context, index),
                  _buildImage(context, index),
                  _buildCommentsAndLikes(context, index),
                  //TODO: tags icons
                  //TODO: reactions
                ],
              ),
            ),
          ),
          onTap: () {
            /*Navigator.of(context).push(
              MaterialPageRoute(builder: (_) {
                return PostScreen(post: null,);
              }),
            );*/
          },
        ));
  }

  Widget _buildTitle(BuildContext context, int index) {
    final Post post = posts[index];
    return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 1,
        ),
        child: Center(
            child: Text(
          post.recipe.title,
          style: PROFILE_HEADLINE_BOLD_BLACK,
          overflow: TextOverflow.ellipsis,
        )));
  }

  Widget _buildImage(BuildContext context, int index) {
    final Post post = posts[index];
    return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 8,
        ),
        child: AspectRatio(
          aspectRatio: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('assets/images/${post.recipe.title}.png',
                fit: BoxFit.fill),
          ),
        ));
  }

  Widget _buildCommentsAndLikes(BuildContext context, int index) {
    final Post post = posts[index];
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Icon(
                  Icons.mode_comment_outlined,
                  color: COLOR_INDIGO_LIGHT,
                  size: 15,
                ),
              ),
              onTap: () {},
            ),
            InkWell(
              child: Icon(_favIconOutlined, color: COLOR_RED, size: 15),
              onTap: () {
                //TODO: individual likes for posts and users
                setState(() {
                  if (_favIconOutlined == Icons.favorite_outline) {
                    _favIconOutlined = Icons.favorite;
                  } else {
                    _favIconOutlined = Icons.favorite_outline;
                  }
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
