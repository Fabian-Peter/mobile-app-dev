import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:diabeatthis/utils/constants.dart';

class PostScreen extends StatelessWidget {
  final DataSnapshot post;
  FirebaseStorage storage = FirebaseStorage.instance;

  IconData _favIconOutlined = Icons.favorite_outline;

  PostScreen({required this.post});

  Future<String> downloadURL(String imageName) async{
    String downloadURL = await storage.ref('image/$imageName').getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(post.child('title').value.toString(),
                style: HEADLINE_BOLD_WHITE),
            actions: <Widget>[_buildProfileIcon(context)]),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: _buildPost(context),
          ),
        ));
  }

  Widget _buildPost(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 7,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCreatorRow(context),
            _buildDescription(context),
            _buildContainerCaption(context, _buildNutrition(), 'Nutrition'),
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

  Widget _buildCreatorRow(BuildContext context) {
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
              //TODO: open user profile
            },
          ),
        ),
        const SizedBox(width: 10),
        Text(
          //post.child('currentUser').value.toString(), //TODO: currentUser to name
          "User",
          style: HOME_POST_CREATOR,
        ),
        const Spacer(),
        _buildDate(context)
      ],
    );
  }

  Widget _buildDate(BuildContext context) {
    DateTime dt = DateTime.parse(post.child('timestamp').value.toString());
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

  Widget _buildDescription(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(post.child('description').value.toString(),
            style: TEXT_PLAIN));
  }

  Widget _buildNutrition() {
    const double iconSize = 54;
    return Row(children: [
      const SizedBox(width: 43),
      Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(iconSize / 2),
          child: Image.asset(
            'assets/images/Fats.png',
            height: iconSize,
            width: iconSize,
          ),
        ),
        const SizedBox(height: 5),
        const Text("Fats: 5g", style: TEXT_PLAIN)
        //TODO: replace with post values
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
        const SizedBox(height: 5),
        const Text("Carbs: 20g", style: TEXT_PLAIN)
        //TODO: replace with post values
      ]),
      const SizedBox(width: 28),
      Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(iconSize / 2),
          child: Image.asset(
            'assets/images/Proteins.png',
            height: iconSize,
            width: iconSize,
          ),
        ),
        const SizedBox(height: 5),
        const Text("Proteins: 13g", style: TEXT_PLAIN)
        //TODO: replace with post values
      ])
    ]);
  }

  Widget _buildImage(BuildContext context) {
    String imageID = post.child("pictureID").value.toString();
    print(imageID);
    
    return FutureBuilder<String>(
        future: downloadURL(imageID),
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

  Widget _buildIngredients(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Text(post.child('ingredients').value.toString(),
            style: TEXT_PLAIN));
  }

  Widget _buildGuide(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Text(post.child('instructions').value.toString(),
            style: TEXT_PLAIN));
  }

  Widget _buildCommunity(BuildContext context) {
    //TODO: add reactions
    //TODO: add comments
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 310),
                child: IconButton(
                  icon: Icon(
                    _favIconOutlined,
                    color: COLOR_RED,
                    size: 27,
                  ),
                  onPressed: () {
                    //TODO: add state to widget?
                  },
                )),
            Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _buildTextRow("Comments:", "No comments yet"))
          ],
        ));
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
                  borderRadius: BorderRadius.circular(12)),
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
