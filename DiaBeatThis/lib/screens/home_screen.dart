import 'dart:convert';
import 'package:diabeatthis/data/dummy_data.dart';
import 'package:diabeatthis/screens/createRecipe_screen.dart';
import 'package:diabeatthis/screens/post_screen.dart';
import 'package:diabeatthis/screens/profile_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:diabeatthis/utils/constants.dart';
import 'package:outline_search_bar/outline_search_bar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cached_network_image/cached_network_image.dart';
import '../classes/Post.dart';
import '../classes/user.dart';
import 'package:badges/badges.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.uid});
  final String? uid;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ref = FirebaseDatabase.instance.ref("post");
  final user = FirebaseAuth.instance.currentUser!;

  IconData _favIconOutlined = Icons.favorite_outline;
  IconData _homeIcon = Icons.home;
  TextEditingController textController = TextEditingController();
  bool isVisible = false;
  List<Post>? posts = DummyData().returnData;
  User userTest = DummyData().user1;
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  late Future<String> dataFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 10,
          title: const Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Text('DiaBeatThis!', style: DIABEATTHIS_LOGO),
          ),
          actions: <Widget>[
            Row(
              children: [_buildLogButton(context), _buildProfileIcon(context)],
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: COLOR_INDIGO,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 25,
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.filter_alt_outlined, color: COLOR_WHITE),
                label: ""),
            BottomNavigationBarItem(
                icon: Icon(_homeIcon, color: COLOR_WHITE), label: ""),
            const BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline, color: COLOR_WHITE),
                label: ""),
          ],
          onTap: (value) {
            if (value == 0) {}
            if (value == 1) {}
            if (value == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateRecipeScreen()));
            }
          },
        ),
        //body: NotificationListener<UserScrollNotification>(
        //  onNotification: (notification) {
        //    if (notification.direction == ScrollDirection.forward) {
        //      if (!isVisible) {
        //        setState(() => isVisible = true);
        //      }
        //    } else if (notification.direction == ScrollDirection.reverse) {
        //      if (isVisible) {
        //        setState(() => isVisible = false);
        //      }
        //    } else if (notification.direction == ScrollDirection.reverse) {
        //      if (isVisible) {
        //        setState(() => isVisible = false);
        //      }
        //    }
        //    return true;
        //  },
        body: PageView(
          controller: controller,
          children: [
            _buildScreen(context, "Home"),
            _buildScreen(context, "Discover")
          ],
          onPageChanged: (page) {
            setState(() {
              if (_homeIcon == Icons.home) {
                _homeIcon = Icons.explore;
              } else {
                _homeIcon = Icons.home;
              }
            });
          },
        ));
  }

  Widget _buildScreen(BuildContext context, String identifier) {
    //TODO: load posts depending on identifier
    return SafeArea(
        child: Column(
      children: [
        const SizedBox(height: 1),
        _buildSearchBar(context),
        Flexible(
            child: FirebaseAnimatedList(
                query: ref.orderByChild('timeSorter'),
                defaultChild: const Text("Loading...", style: TEXT_PLAIN),
                itemBuilder: (context, snapshot, animation, index) {
                  return _buildPosts(context, snapshot, index);
                }))
      ],
    ));
  }

  Widget _buildLogButton(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 13),
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
                onPressed: () => FirebaseAuth.instance.signOut())));
  }

  Widget _buildProfileIcon(BuildContext context) {
    final User profile = userTest;
    return ClipRRect(
      borderRadius: BorderRadius.circular(PROFILE_ICON_BAR_SIZE / 2),
      child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            child: Image.asset(
              //TODO: if guest, then show anonymous profile icon
              'assets/images/Profile.png',
              //TODO: replace with user image
              height: PROFILE_ICON_BAR_SIZE,
              width: PROFILE_ICON_BAR_SIZE,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) {
                  return const ProfileScreen();
                }),
              );
            },
            //TODO: open profile instead
          )),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return const SizedBox(
        width: 400,
        height: 48,
        child: OutlineSearchBar(
            margin: EdgeInsets.only(top: 7, bottom: 6, left: 8, right: 8),
            borderColor: COLOR_INDIGO,
            textStyle: TEXT_PLAIN));
  }

  Widget _buildPosts(BuildContext context, DataSnapshot snapshot, int index) {
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
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCreator(context, snapshot, index),
                  _buildTitle(context, snapshot, index),
                  _buildImage(context, snapshot, index),
                  _buildDescription(context, snapshot, index),
                  _buildCommentsAndLikes(context, snapshot, index),
                  //TODO: tags icons
                  //TODO: reactions
                ],
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) {
                return PostScreen(post: snapshot);
              }),
            );
          },
        ));
  }

  Widget _buildCreator(BuildContext context, DataSnapshot snapshot, int index) {
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
                onTap: () {
                  //TODO: open user profile
                },
              )),
        ),
        Text(
          //post.child('currentUser').value.toString(), //TODO: currentUser to name
          "User",
          style: HOME_POST_CREATOR,
        )
      ],
    );
  }

  Widget _buildTitle(BuildContext context, DataSnapshot snapshot, int index) {
    return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 1,
        ),
        child: Center(
            child: Text(snapshot.child('title').value.toString(),
                style: HEADLINE_BOLD_BLACK)));
  }

  Widget _buildImage(BuildContext context, DataSnapshot snapshot, int index) {
    String url = snapshot.child('pictureID').value.toString();
    return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 8,
        ),
        child: AspectRatio(
          aspectRatio: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
            ),
          ),
        ));
  }

  Widget _buildDescription(
      BuildContext context, DataSnapshot snapshot, int index) {
    return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Center(
            child: Text(snapshot.child('description').value.toString(),
                style: TEXT_PLAIN)));
  }

  Widget _buildCommentsAndLikes(
      BuildContext context, DataSnapshot snapshot, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
    Badge(
      position: BadgePosition.topEnd(top: 2, end: 1),
      badgeColor: Colors.blueAccent,
      badgeContent: Text(snapshot.child('commentsAmount').value.toString()),
      child: IconButton(
          icon: const Icon(
            Icons.comment_bank_sharp,
            color: COLOR_INDIGO_LIGHT,
            size: 20,
          ),
          onPressed: () {},
        ),
    ),

    Badge(
        position: BadgePosition.topEnd(top: 2, end: 1),
    badgeContent: Text(snapshot.child('commentsAmount').value.toString()),
    child: IconButton(
          icon: Icon(
            _favIconOutlined,
            color: Colors.red,
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
    )],
    );
  }
}
