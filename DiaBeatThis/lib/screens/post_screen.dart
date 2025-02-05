import 'package:diabeatthis/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:diabeatthis/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'package:diabeatthis/screens/Comments_Screen.dart';

class PostScreen extends StatefulWidget {
  final DataSnapshot post;

  const PostScreen({super.key, required this.post});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  //Firebase variables
  final ref = FirebaseDatabase.instance.ref("Users");
  String ownName = FirebaseAuth.instance.currentUser!.uid;
  final database = FirebaseDatabase.instance.refFromURL(
      "https://diabeathis-f8ee3-default-rtdb.europe-west1.firebasedatabase.app");
  String currentUser = FirebaseAuth.instance.currentUser!.uid.toString();
  late DataSnapshot queryReference;

  //Page variables
  IconData icon = Icons.favorite;
  TextEditingController commentsController = TextEditingController();

  Future<String> downloadURL(String imageName) async {
    String downloadURL =
        await FirebaseStorage.instance.ref('image/$imageName').getDownloadURL();
    return downloadURL;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.post.child('likes/$ownName').value.toString().contains('true')) {
      icon = Icons.favorite;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.child('title').value.toString(),
            style: HEADLINE_BOLD_WHITE),
        actions: <Widget>[
          Row(
            children: [_buildProfileIcon(context)],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: _buildPost(context, widget.post),
        ),
      ),
    );
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
            _buildImage(context),
            _buildContainerCaption(
                context, _buildNutrition(), 'Nutritional Values'),
            _buildContainerCaption(
                context, _buildIngredients(context), 'Ingredients'),
            _buildContainerCaption(
                context, _buildGuide(context), 'Instructions'),
            _buildCommunity(context, snapshot),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorRow(BuildContext context, DataSnapshot snapshot) {
    return Row(
      children: [
        UserNameToID(
          username: snapshot.child('currentUser').value.toString(),
          builder: (context, snapshot) {
            final userID = snapshot.data;
            return InkWell(
              onTap: userID == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) {
                          return ProfileScreen(userID: userID);
                        }),
                      );
                    },
              child: UserProfileImage(
                  userID: userID, iconSize: PROFILE_ICON_BAR_SIZE),
            );
          },
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
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        child: UserProfileImage(
          userID: currentUser,
          iconSize: PROFILE_ICON_BAR_SIZE,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) {
              return FirebaseAuth.instance.currentUser!.isAnonymous
                  ? AuthScreen()
                  : ProfileScreen(userID: currentUser);
            }),
          );
        },
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
    String tags = widget.post.child('tags').value.toString();
    return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Text(tags.substring(1, tags.length - 1), style: TEXT_PLAIN));
  }

  Widget _buildNutrition() {
    return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Text(widget.post.child("nutrition").value.toString()));
  }

  Widget _buildImage(BuildContext context) {
    String imageID = widget.post.child("pictureID").value.toString();
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(imageUrl: imageID, fit: BoxFit.cover),
          ),
        ));
  }

  Widget _buildIngredients(BuildContext context) {
    int length = widget.post.child('ingredients').children.length;
    String ingredientString = "";

    for (int i = 0; i < length; i++) {
      if (i != 0) {
        ingredientString += ", ";
      }
      ingredientString +=
          "${widget.post.child('ingredientsQuantity').child(i.toString()).value} ${widget.post.child('ingredients').child(i.toString()).value}";
    }

    return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Text(ingredientString, style: TEXT_PLAIN));
  }

  Widget _buildGuide(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Text(widget.post.child('instructions').value.toString(),
            style: TEXT_PLAIN));
  }

  Widget _buildCommunity(BuildContext context, DataSnapshot snapshot) {
    String commentsAmount =
        widget.post.child('CommentsAmount').value.toString();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        const Spacer(),
        Badge(
            borderRadius: BorderRadius.circular(8),
            position: BadgePosition.topEnd(top: -1, end: 3),
            badgeColor: COLOR_INDIGO,
            badgeContent:
                Text(commentsAmount, style: TextStyle(color: Colors.white)),
            child: IconButton(
                icon: const Icon(
                  Icons.comment_rounded,
                  color: COLOR_INDIGO,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return CommentsScreen(post: widget.post);
                      },
                    ),
                  );
                })),
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

  void dispose() {
    commentsController.dispose();
    super.dispose();
  }

  void clearText() {
    commentsController.clear();
  }
}
