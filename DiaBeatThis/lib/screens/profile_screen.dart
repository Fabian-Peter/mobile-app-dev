import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:diabeatthis/screens/home_screen.dart';
import 'package:diabeatthis/screens/settings_screen.dart';
import 'package:diabeatthis/utils/constants.dart';
import 'package:diabeatthis/screens/post_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:rxdart/rxdart.dart';

import '../classes/Post.dart';
import '../classes/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ref = FirebaseDatabase.instance.ref("post");
  final database = FirebaseDatabase.instance.refFromURL(
      "https://diabeathis-f8ee3-default-rtdb.europe-west1.firebasedatabase.app");
  String? currentUser = FirebaseAuth.instance.currentUser?.uid.toString();

  Key listKey = Key(DateTime.now().millisecondsSinceEpoch.toString());

  IconData _favIconOutlined = Icons.favorite_outline;
  IconData icon = Icons.favorite_border_outlined;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10,
        title: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Username(userID: currentUser)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 3),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UserProfileImage(userID: currentUser),
                    _buildEditIcon(context),
                    //_buildProfile(context),
                    Userposts(userID: currentUser)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

/*  Widget _buildProfile(BuildContext context, DataSnapshot snapshot, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      child: Column(children: [
        Row(
          children: [
            //_buildNumberOfPosts(context)
          ],
        ),
        _buildPosts(context, snapshot, index)
      ]),
    );
  }*/

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

}

Widget _buildPosts(BuildContext context, DataSnapshot snapshot) {
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
              _buildTitle(context, snapshot),
              _buildImage(context, snapshot),
              //_buildCommentsAndLikes(context, snapshot),
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

Widget _buildTitle(BuildContext context, DataSnapshot snapshot) {
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
}

Widget _buildImage(BuildContext context, DataSnapshot snapshot) {
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
}

/*Widget _buildCommentsAndLikes(
      BuildContext context, DataSnapshot snapshot) {
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
    ]);*/

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
    );}*/

class Username extends StatefulWidget {
  const Username({Key? key, required this.userID}) : super(key: key);
  final String? userID;

  @override
  State<Username> createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  late final Stream<String?> username;

  @override
  void initState() {
    username = getUsername();
    super.initState();
  }

  Stream<String?> getUsername() {
    return FirebaseDatabase.instance
        .ref('Users/${widget.userID}/username')
        .onValue
        .map((event) => event.snapshot.value?.toString());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: username,
      initialData: "",
      builder: (context, snapshot) {
        final username = snapshot.data!;
        return Text(
          username,
          style: HEADLINE_BOLD_WHITE,
        );
      },
    );
  }
}

class Userposts extends StatefulWidget {
  const Userposts({Key? key, required this.userID}) : super(key: key);
  final String? userID;

  @override
  State<Userposts> createState() => _UserpostsState();
}

class _UserpostsState extends State<Userposts> {
  late final Stream<List<DataSnapshot>> userposts;

  @override
  void initState() {
    userposts = getUserposts();
    super.initState();
  }

  Stream<List<DataSnapshot>> getUserposts() {
    final posts = FirebaseDatabase.instance
        .ref('post')
        .orderByChild("timeSorter")
        .onValue
        .map((event) => event.snapshot.children);

    final username = getUsername();

    return CombineLatestStream.combine2(
        posts,
        username,
        (posts, username) => posts
            .where((element) =>
                element.child("username").value!.toString() == username)
            .toList());
  }

  Stream<String?> getUsername() {
    return FirebaseDatabase.instance
        .ref('Users/${widget.userID}/username')
        .onValue
        .map((event) => event.snapshot.value?.toString());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DataSnapshot>>(
      stream: userposts,
      initialData: null,
      builder: (context, snapshot) {
        final userposts = snapshot.data;
        if (userposts == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          primary: false,
          padding: const EdgeInsets.all(5),
          itemCount: userposts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 200 / 200),
          itemBuilder: (context, index) {
            return _buildPosts(context, userposts[index]);
          },
        );
      },
    );
  }
}
