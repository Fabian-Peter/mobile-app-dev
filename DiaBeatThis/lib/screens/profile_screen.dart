import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:diabeatthis/screens/settings_screen.dart';
import 'package:diabeatthis/utils/constants.dart';
import 'package:diabeatthis/screens/post_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:diabeatthis/data/dummy_data.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../classes/Post.dart';
import '../classes/user.dart';

class ProfileScreen extends StatefulWidget {
  final DataSnapshot user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ref = FirebaseDatabase.instance.ref("post");
  final database = FirebaseDatabase.instance.refFromURL(
      "https://diabeathis-f8ee3-default-rtdb.europe-west1.firebasedatabase.app");
  late Query query = ref.orderByChild('timeSorter');
  String? currentUser = FirebaseAuth.instance.currentUser?.uid.toString();

  Key listKey = Key(DateTime.now().millisecondsSinceEpoch.toString());


  //final User profile = DummyData().user1;
  IconData _favIconOutlined = Icons.favorite_outline;
  IconData icon = Icons.favorite_border_outlined;
  late Future<String> dataFuture;
  late String _username;
  String searchWord = "";


  @override
  void initState() {
    IconData icon = Icons.favorite_border_outlined;
    super.initState();
  }

  Future<DataSnapshot> getUsername() async {
    DataSnapshot snapshot1 =
    await FirebaseDatabase.instance.ref('Users/$currentUser/username').get();
    String username = await snapshot1.value.toString();
    return snapshot1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        onPanDown: (_) => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 10,
            title: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(widget.user.child('username').value.toString(),
                  style: HEADLINE_BOLD_WHITE),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 3),
                Flexible(
                  child: FirebaseAnimatedList(
                      query: ref.orderByChild('timeSorter'),
                      defaultChild: const Text("Loading...", style: TEXT_PLAIN),
                      itemBuilder: (context, snapshot, animation, index) {
                        return _buildProfile(context, snapshot, index);
                      }),
                ),
              ],
            ),
          ),

          /*SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileIcon(context),
                  //_buildUsername(context),
                  //_buildEditIcon(context),
                  //_buildProfile(context),
                  _buildListOfPosts(context)
                ],
              ),
            ),
          ),*/
        ));
  }

  Widget _buildProfile(BuildContext context, DataSnapshot snapshot, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      child: Column(children: [
        Row(
          children: [
            _buildProfileIcon(context, snapshot, index),
            _buildUsername(context, snapshot, index)
            //_buildNumberOfPosts(context),
            //_buildFollower(context),
            //_buildFollowing(context)
          ],
        ),
        _buildPosts(context, snapshot, index)
      ]),
    );
  }


  Widget _buildProfileIcon(BuildContext context, snapshot, index) {
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
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 3),
          Flexible(
            child: FirebaseAnimatedList(
                query: ref.orderByChild('timeSorter'),
                defaultChild: const Text("Loading...", style: TEXT_PLAIN),
                itemBuilder: (context, snapshot, animation, index) {
                  return _buildProfile(context, snapshot, index);
                }),
          ),
        ],
      ),
    );

/*    return StreamBuilder<Query>(
      initialData: ref.orderByChild("timeSorter"),
      stream: ref.orderByChild("timeSorter"),
      builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
        if (snapshot.hasData) {
          Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
          map.forEach((key, value) => print(value["pictureID"]));

          return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              primary: false,
              padding: const EdgeInsets.all(5),
              itemCount: map.values.toList().length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 200 / 200),
              itemBuilder: (context, index) {
                return _buildPosts(context, index);
              });
        }
      },
    );*/
  }
/*  Widget _buildNumberOfPosts(
      BuildContext context, DataSnapshot snapshot, int index) {
    //Todo return len of list and create new screen with Posts list
    return Expanded(
      child: Column(children: [
        Text(posts.length.toString(), style: TEXT_BOLD),
        const SizedBox(height: 4),
        const Text("Posts", style: TEXT_PLAIN)
      ]),
    );
  }*/

  Widget _buildUsername(
      BuildContext context, DataSnapshot snapshot, int index) {
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
                _buildTitle(context, snapshot, index),
                _buildImage(context, snapshot, index),
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
      ),
    );
  }

  /*Widget _buildPosts(BuildContext context, int index) {
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
          */ /*Navigator.of(context).push(
              MaterialPageRoute(builder: (_) {
                return PostScreen(post: null,);
              }),
            );*/ /*
        },
      ),
    );
  }*/

  Widget _buildTitle(BuildContext context, DataSnapshot snapshot, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 1,
      ),
      child: Center(
        child: Text(snapshot.child('title').value.toString(),
            style: HEADLINE_BOLD_BLACK),
      ),
    );

    /*final Post post = posts[index];
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
        ),
      ),
    );*/
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
            placeholder: (context, url) => const CircularProgressIndicator(),
          ),
        ),
      ),
    );

    /*final Post post = posts[index];
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
      ),
    );*/
  }

  Widget _buildCommentsAndLikes(
      BuildContext context, DataSnapshot snapshot, int index) {
    String ref = snapshot.child('reference').value.toString();
    String ownName = FirebaseAuth.instance.currentUser!.uid;
    var likesAmount = snapshot.child('likeAmount').value.toString();
    print(snapshot.child('likes/$ownName').value.toString());
    if (snapshot.child('likes/$ownName').value.toString() == 'true') {
      print('working until here');
    }
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Badge(
        borderRadius: BorderRadius.circular(8),
        position: BadgePosition.topEnd(top: 1, end: -3),
        badgeColor: COLOR_INDIGO_LIGHT,
        badgeContent: const Text('0', style: TextStyle(color: Colors.white)),
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
        borderRadius: BorderRadius.circular(8),
        position: BadgePosition.topEnd(top: 1, end: -3),
        badgeColor: Colors.red,
        badgeContent:
            Text(likesAmount, style: const TextStyle(color: Colors.white)),
        child: IconButton(
          icon: Icon(
            icon,
            color: Colors.red,
            size: 20,
          ),
          onPressed: () {
            String result = snapshot.child('likes/$ownName').value.toString();
            //print(snapshot.child('likes/$ownName').value.toString());
            //print (result);
            if (result == 'true') {
              database.child('post/$ref/likes/$ownName').set('false');
              print('removed like');
              database
                  .child('post/$ref/likeAmount')
                  .set(ServerValue.increment(-1));
              icon = Icons.favorite_border_outlined;
              setState(() {});
            } else {
              database.child('post/$ref/likes/$ownName').set('true');
              database
                  .child('post/$ref/likeAmount')
                  .set(ServerValue.increment(1));
              print('added like');
              icon = Icons.favorite;
              setState(() {});
            }
          },
        ),
      )
    ]);

    /*final Post post = posts[index];
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
    );*/
  }
}
