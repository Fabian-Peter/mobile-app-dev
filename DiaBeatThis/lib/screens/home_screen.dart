import 'package:diabeatthis/data/dummy_data.dart';
import 'package:diabeatthis/screens/createRecipe_screen.dart';
import 'package:diabeatthis/screens/post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diabeatthis/utils/constants.dart';
import 'package:anim_search_bar/anim_search_bar.dart';

import '../classes/Post.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  IconData _favIconOutlined = Icons.favorite_outline;
  IconData _newIcon = Icons.fiber_new;
  TextEditingController textController = TextEditingController();
  bool isVisible = false;
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
        titleSpacing: 10,
        title: const Padding(
          padding: EdgeInsets.only(top: 14),
          child: Text('DiaBeatThis!', style: DIABEATTHIS_LOGO),
        ),
        actions: <Widget>[
          Row(
            children: [_buildLogButton(context), _buildProfileIcon(context)],
          )
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: Row(
              children: [_buildFiltersRow(context)],
            )),
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.forward) {
            if (!isVisible) {
              setState(() => isVisible = true);
            }
          } else if (notification.direction == ScrollDirection.reverse) {
            if (isVisible) {
              setState(() => isVisible = false);
            }
          } else if (notification.direction == ScrollDirection.reverse) {
            if (isVisible) {
              setState(() => isVisible = false);
            }
          }
          return true;
        },
        child: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(top: 7),
              child: ListView.builder(itemBuilder: (context, index) {
                return _buildPosts(context, index);
              })),
        ),
      ),
      floatingActionButton: isVisible
          ? FloatingActionButton(
              heroTag: "createButton",
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

  Widget _buildLogButton(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 13, top: 7),
        child: SizedBox(
            height: 28,
            width: 100,
            child: FloatingActionButton.extended(
                heroTag: "logButton",
                backgroundColor: COLOR_WHITE,
                label: FirebaseAuth.instance.currentUser!.isAnonymous
                    ? const Text("Login", style: LOGBUTTON)
                    : const Text("Logout", style: LOGBUTTON),
                icon: Icon(
                    FirebaseAuth.instance.currentUser!.isAnonymous
                        ? Icons.login
                        : Icons.logout,
                    size: 19.0,
                    color: COLOR_INDIGO),
                onPressed: () => _signout())));
  }

  Widget _buildProfileIcon(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(PROFILE_ICON_BAR_SIZE / 2),
      child: Padding(
          padding: const EdgeInsets.only(right: 10, top: 8),
          child: InkWell(
              child: Image.asset(
                //TODO: if guest, then show anonymous profile icon
                'assets/images/Profile.png',
                //TODO: replace with user image
                height: PROFILE_ICON_BAR_SIZE,
                width: PROFILE_ICON_BAR_SIZE,
              ),
              onTap: () {
                //TODO: open profile instead
              })),
    );
  }

  Widget _buildFiltersRow(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: IconButton(
            icon: Icon(
              _newIcon,
              color: COLOR_WHITE,
              size: 35,
            ),
            onPressed: () {
              //TODO: switch between new and popular posts
              setState(() {
                if (_newIcon == Icons.fiber_new) {
                  _newIcon = Icons.star;
                } else {
                  _newIcon = Icons.fiber_new;
                }
              });
            },
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: IconButton(
              icon: const Icon(
                Icons.filter_list_alt,
                color: COLOR_WHITE,
                size: 35,
              ),
              onPressed: () {
                //TODO: implement filter option
              },
            )),
        SizedBox(
            width: 290,
            height: 40,
            child: AnimSearchBar(
              rtl: true,
              width: 270,
              textController: textController,
              onSuffixTap: () {
                setState(() {
                  textController.clear();
                });
              },
              onSubmitted: (String) {},
            ))
      ],
    );
  }

  Widget _buildPosts(BuildContext context, int index) {
    final Post post = posts![index];
    return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 7,
        ),
        child: InkWell(
          child: Container(
            decoration: BoxDecoration(
              color: COLOR_WHITE,
              border: Border.all(width: 6, color: COLOR_INDIGO_LIGHT),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCreator(context, index),
                  _buildTitle(context, index),
                  _buildImage(context, index),
                  _buildDescription(context, index),
                  _buildCommentsAndLikes(context, index),
                  //TODO: tags icons
                  //TODO: reactions
                ],
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) {
                return PostScreen(post: post);
              }),
            );
          },
        ));
  }

  Widget _buildCreator(BuildContext context, int index) {
    final Post post = posts![index]; //TODO: remove +1
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(USER_ICON_POST_SIZE / 2),
              child: InkWell(
                child: Image.asset(
                  'assets/images/Avatar.png', //TODO: replace with user image
                  height: USER_ICON_POST_SIZE,
                  width: USER_ICON_POST_SIZE,
                ),
                onTap: () { //TODO: open user profile
                },
              )),
        ),
        Text(
          post.creator.name,
          style: HOME_POST_CREATOR,
        )
      ],
    );
  }

  Widget _buildTitle(BuildContext context, int index) {
    final Post post = posts![index];
    return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 1,
        ),
        child:
            Center(child: Text(post.recipe.title, style: HEADLINE_BOLD_BLACK)));
  }

  Widget _buildImage(BuildContext context, int index) {
    final Post post = posts![index];
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

  Widget _buildDescription(BuildContext context, int index) {
    final Post post = posts![index];
    return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Center(child: Text(post.recipe.description, style: TEXT_PLAIN)));
  }

  Widget _buildCommentsAndLikes(BuildContext context, int index) {
    final Post post = posts![index];
    return Row(
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 260),
            child: IconButton(
              icon: const Icon(
                Icons.mode_comment_outlined,
                color: COLOR_INDIGO_LIGHT,
                size: 20,
              ),
              onPressed: () {},
            )),
        IconButton(
          icon: Icon(
            _favIconOutlined,
            color: COLOR_RED,
            size: 20,
          ),
          onPressed: () {
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
    );
  }
}
