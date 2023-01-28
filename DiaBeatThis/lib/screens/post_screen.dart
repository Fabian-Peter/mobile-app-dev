import 'package:diabeatthis/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:diabeatthis/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class PostScreen extends StatefulWidget {
  final DataSnapshot post;

  const PostScreen({super.key, required this.post});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;
  final database = FirebaseDatabase.instance.refFromURL(
      "https://diabeathis-f8ee3-default-rtdb.europe-west1.firebasedatabase.app");
  final IconData _favIconOutlined = Icons.favorite_outline;
  IconData icon = Icons.favorite_border_outlined;
  final ref = FirebaseDatabase.instance.ref("Users");
  String? currentUser = FirebaseAuth.instance.currentUser?.uid.toString();
  Future<String> downloadURL(String imageName) async {
    String downloadURL = await storage.ref('image/$imageName').getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.post.child('title').value.toString(),
              style: HEADLINE_BOLD_WHITE),
          actions: <Widget>[
            _buildProfileIcon(context),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: FirebaseAnimatedList(
              shrinkWrap: true,
              query: ref,
              defaultChild: const Text("Loading...", style: TEXT_PLAIN),
              itemBuilder: (context, snapshot, animation, index) {
                return _buildPost(context, snapshot);
              },
            ),
          ),
        ));
  }

  Widget _buildPost(BuildContext context, DataSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 7,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCreatorRow(context, snapshot),
            _buildDescription(context),
            _buildContainerCaption(context, _buildTags(), 'Tags'),
            _buildContainerCaption(
                context, _buildNutrition(), 'Nutritional Values'),
            _buildImage(context),
            _buildContainerCaption(
                context, _buildIngredients(context), 'Ingredients'),
            _buildContainerCaption(
                context, _buildGuide(context), 'Instructions'),
            _buildCommunity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorRow(BuildContext context, DataSnapshot snapshot) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(USER_ICON_POST_SIZE / 2),
          child: InkWell(
            child: Image.asset(
              'assets/images/Avatar.png', //TODO: replace with user image
              height: USER_ICON_POST_SIZE,
              width: USER_ICON_POST_SIZE,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) {
                  return FirebaseAuth.instance.currentUser!.isAnonymous
                      ? AuthScreen()
                      : ProfileScreen();
                }),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Text(
          widget.post.child('currentUser').value.toString(),
          style: HOME_POST_CREATOR,
        ),
        const Spacer(),
        _buildDate(context)
      ],
    );
  }

  Widget _buildDate(BuildContext context) {
    DateTime dt =
        DateTime.parse(widget.post.child('timestamp').value.toString());
    return Row(
      children: [
        const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(Icons.calendar_month_rounded, size: 13)),
        const SizedBox(width: 5),
        Text("${dt.day}.${dt.month}.${dt.year}", style: TEXT_BOLD)
      ],
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(PROFILE_ICON_BAR_SIZE / 2),
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: InkWell(
          child: UserProfileImage(
            userID: currentUser,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) {
                return FirebaseAuth.instance.currentUser!.isAnonymous
                    ? AuthScreen()
                    : ProfileScreen();
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(widget.post.child('description').value.toString(),
            style: TEXT_PLAIN));
  }

  Widget _buildTags() {
    return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Text(
            widget.post
                .child('tags')
                .value
                .toString(), //TODO: Liste berücksichtigen
            style: TEXT_PLAIN));
  }

  Widget _buildNutrition() {
    const double iconSize = 54;
    return Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(iconSize / 2),
                  child: Image.asset(
                    'assets/images/Fats.png',
                    height: iconSize,
                    width: iconSize,
                  ),
                ),
              ]),
              const SizedBox(width: 30),
              Column(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(iconSize / 2),
                  child: Image.asset(
                    'assets/images/Carbs.png',
                    height: iconSize,
                    width: iconSize,
                  ),
                ),
              ]),
              const SizedBox(width: 30),
              Column(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(iconSize / 2),
                  child: Image.asset(
                    'assets/images/Proteins.png',
                    height: iconSize,
                    width: iconSize,
                  ),
                ),
              ])
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.post.child("nutrition").value.toString())
        ]));
  }

  Widget _buildImage(BuildContext context) {
    String imageID = widget.post.child("pictureID").value.toString();
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: AspectRatio(
          aspectRatio: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(imageUrl: imageID, fit: BoxFit.cover),
          ),
        ));
  }

  Widget _buildIngredients(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Text(widget.post.child('ingredients').value.toString(),
            style: TEXT_PLAIN));
  }

  Widget _buildGuide(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Text(widget.post.child('instructions').value.toString(),
            style: TEXT_PLAIN));
  }

  Widget _buildCommunity(BuildContext context) {
    //TODO: add reactions
    //TODO: add comments
    String ref = widget.post.child('reference').value.toString();
    var likesAmount = widget.post.child('likeAmount').value.toString();
    String ownName = FirebaseAuth.instance.currentUser!.uid;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(right: 310),
          child: Badge(
              borderRadius: BorderRadius.circular(8),
              position: BadgePosition.topEnd(top: 1, end: -3),
              badgeColor: Colors.red,
              badgeContent:
                  Text(likesAmount, style: TextStyle(color: Colors.white)),
              child: IconButton(
                icon: Icon(
                  icon,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: () {
                  // String result = widget.post.child('likes/$ownName').value.toString();
                  // print(widget.post.child('likes/$ownName').value.toString());
                  // //print(snapshot.child('likes/$ownName').value.toString());
                  // //print (result);
                  // if (result == 'true') {
                  //   database.child('post/$ref/likes/$ownName').set('false');
                  //   print('removed like');
                  //   database.child('post/$ref/likeAmount').set(ServerValue.increment(-1));
                  //   icon = Icons.favorite_border_outlined;
                  //   setState(() {
                  //   });
                  // } else {
                  //   database.child('post/$ref/likes/$ownName').set('true');
                  //   database.child('post/$ref/likeAmount').set(ServerValue.increment(1));
                  //   print('added like');
                  //   icon = Icons.favorite;
                  //   setState(() {
                  //  });
                  // }
                },
              )),
        )
      ]),
    );
  }

  Widget _buildContainerCaption(
      BuildContext context, Widget widget, String caption) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Stack(
        children: <Widget>[
          Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              width: 370,
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
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: 5, top: 5, right: 5, bottom: 5),
                  child: Column(
                    children: [
                      widget,
                    ],
                  ))),
          Positioned(
              left: 30,
              top: 0,
              child: Container(
                padding:
                    const EdgeInsets.only(bottom: 2, top: 2, left: 7, right: 7),
                color: COLOR_WHITE,
                child: Text(
                  caption,
                  style: POST_CAPTION_INDIGO_LIGHT,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTextRow(String key, String value) {
    return Row(
      children: [
        Text(
          key,
          style: TEXT_BOLD,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TEXT_PLAIN,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
