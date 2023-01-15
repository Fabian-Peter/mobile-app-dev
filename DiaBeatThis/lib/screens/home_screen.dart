import 'dart:math';

import 'package:diabeatthis/data/dummy_data.dart';
import 'package:diabeatthis/screens/createRecipe_screen.dart';
import 'package:diabeatthis/screens/post_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diabeatthis/utils/constants.dart';
import 'package:outline_search_bar/outline_search_bar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../classes/Post.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ref = FirebaseDatabase.instance.ref("post");

  IconData _favIconOutlined = Icons.favorite_outline;
  IconData _newIcon = Icons.fiber_new_outlined;
  TextEditingController textController = TextEditingController();
  bool isVisible = false;
  List<Post>? posts = DummyData().returnData;
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _signout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<String> downloadURL(String imageName) async{
    String downloadURL = await storage.ref('image/$imageName').getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10,
        title: const Padding(
          padding: EdgeInsets.only(top: 11),
          child: Text('DiaBeatThis!', style: DIABEATTHIS_LOGO),
        ),
        actions: <Widget>[
          Row(
            children: [_buildProfileIcon(context)],
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: COLOR_INDIGO,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 25,
        items: [
          BottomNavigationBarItem(
              icon: Icon(_newIcon, color: COLOR_WHITE), label: ""),
          const BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, color: COLOR_WHITE),
              label: ""),
          const BottomNavigationBarItem(
              icon: Icon(Icons.filter_alt_outlined, color: COLOR_WHITE),
              label: ""),
        ],
        onTap: (value) {
          if (value == 0) {
            setState(() {
              if (_newIcon == Icons.fiber_new_outlined) {
                _newIcon = Icons.star_border;
              } else {
                _newIcon = Icons.fiber_new_outlined;
              }
            });
          }
          if (value == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateRecipeScreen()));
          }
          if (value == 2) {}
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
        body: SafeArea(
            child: Column(
          children: [
            const SizedBox(height: 1),
            _buildSearchBar(context),
            Flexible(
                child: FirebaseAnimatedList(
                    query: ref,
                    defaultChild: const Text("Loading...", style: TEXT_PLAIN),
                    itemBuilder: (context, snapshot, animation, index) {
                      return _buildPosts(context, snapshot, index);
                    }))
          ],
        )),

    );
  }

  Widget _buildProfileIcon(BuildContext context) {
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
                //TODO: open profile instead
              })),
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

 Widget _buildImage(BuildContext context, DataSnapshot snapshot, int index){
   String tempUrl = snapshot.child('pictureID').value.toString();
   return FutureBuilder<String>(
     future: downloadURL(tempUrl),
     builder: (context, AsyncSnapshot<String> snapshot) {
       if (snapshot.connectionState == ConnectionState.waiting) {
         return const CircularProgressIndicator.adaptive();
       }
       if (snapshot.hasError) {
         return Text(snapshot.error.toString());
       }
       else {
          print (snapshot);
         return Padding(
             padding: const EdgeInsets.symmetric(
               horizontal: 9,
               vertical: 8,
             ),
             child: AspectRatio(
               aspectRatio: 2,
               child: ClipRRect(
                 borderRadius: BorderRadius.circular(10),
                 child: Image.network(snapshot.data!,
                     //TODO: ersetzen mit bild
                     fit: BoxFit.fill),
               ),
             ));
       }

     }
   );
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
