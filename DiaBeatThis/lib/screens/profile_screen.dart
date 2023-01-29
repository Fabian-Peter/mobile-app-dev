import 'package:cached_network_image/cached_network_image.dart';
import 'package:diabeatthis/screens/home_screen.dart';
import 'package:diabeatthis/screens/settings_screen.dart';
import 'package:diabeatthis/utils/constants.dart';
import 'package:diabeatthis/screens/post_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.userID}) : super(key: key);
  final String userID;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ref = FirebaseDatabase.instance.ref("post");

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
            child: Username(userID: widget.userID)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 25),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UserProfileImage(userID: widget.userID, iconSize: 120),
                    _buildEditIcon(context),
                    Userposts(userID: widget.userID)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
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
}

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
  IconData icon = Icons.favorite_border_outlined;
  final database = FirebaseDatabase.instance.refFromURL(
      "https://diabeathis-f8ee3-default-rtdb.europe-west1.firebasedatabase.app");

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

    return CombineLatestStream.combine2(posts, username, (posts, username) {
      return posts.where((element) {
        return element.child("currentUser").value!.toString() == username;
      }).toList();
    });
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

  Widget _buildPosts(BuildContext context, DataSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTitle(context, snapshot),
                _buildImage(context, snapshot),
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
      padding: const EdgeInsets.only(left: 10, right: 10, top: 9, bottom: 4),
      child: Center(
        child: Text(
          snapshot.child('title').value.toString(),
          style: POST_CAPTION_BLACK_PROFILE,
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, DataSnapshot snapshot) {
    String url = snapshot.child('pictureID').value.toString();
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, bottom: 10),
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
}
