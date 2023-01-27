import 'package:cached_network_image/cached_network_image.dart';
import 'package:diabeatthis/screens/post_screen.dart';
import 'package:diabeatthis/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:swipe_cards/swipe_cards.dart';

import 'auth_screen.dart';

class GameScreen extends StatefulWidget { //TODO: add if's for swipe order
  GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final List<String> _names = [
    "Fish",
    "Meat",
    "Vegetarian",
    "Vegan",
    "Pasta",
    "Rice",
    "Gluten free",
    "Dessert",
    "Quick & Easy"
  ]; //TODO: add ingredients?

  final List<String> _images = [
    'assets/images/Greek salad with feta.png',
    'assets/images/Grilled Alaska fish.png',
    'assets/images/Vegan BBQ Burger.png',
    'assets/images/recipeCamera.png',
    'assets/images/Avatar.png',
    'assets/images/Greek salad with feta.png',
    'assets/images/Grilled Alaska fish.png',
    'assets/images/Vegan BBQ Burger.png',
    'assets/images/recipeCamera.png'
  ]; //TODO: add new pictures

  final List<String> swipedRight = [];

  @override
  void initState() {
    for (int i = 0; i < _names.length; i++) {
      _swipeItems.add(SwipeItem(
          content: Content(text: _names[i], image: _images[i]),
          likeAction: () {
            swipedRight.add(_names[i]);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Liked ${_names[i]}"),
              duration: const Duration(milliseconds: 500),
            ));
          }));
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text("Tinder"),
        ),
        body: Center(
            child: Column(
          children: [
            const SizedBox(height: 40),
            SizedBox(
                width: 300,
                height: 500,
                child: Stack(children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - kToolbarHeight,
                    child: SwipeCards(
                      matchEngine: _matchEngine!,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: AssetImage(_swipeItems[index].content.image),
                            fit: BoxFit.fill,
                          )),
                          child: Text(
                            _swipeItems[index].content.text,
                            style: const TextStyle(
                                fontSize: 50,
                                fontFamily: 'VisbyDemiBold',
                                color: Colors.white),
                          ),
                        );
                      },
                      onStackFinished: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GameResultScreen(
                                    swipedRight:
                                        swipedRight))); //TODO: back to home screen instead tinder game
                      },
                      leftSwipeAllowed: true,
                      rightSwipeAllowed: true,
                      upSwipeAllowed: false,
                      fillSpace: true,
                    ),
                  ),
                ])),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            _matchEngine!.currentItem?.nope();
                          },
                          icon: const Icon(Icons.cancel),
                          iconSize: 50,
                          color: COLOR_INDIGO),
                      IconButton(
                          onPressed: () {
                            _matchEngine!.currentItem?.like();
                          },
                          icon: const Icon(Icons.favorite),
                          iconSize: 50,
                          color: COLOR_INDIGO),
                    ],
                  ),
                ))
          ],
        )));
  }
}

class Content {
  final String text;
  final String image;

  Content({required this.text, required this.image});
}

class GameResultScreen extends StatelessWidget {
  final ref = FirebaseDatabase.instance.ref("post");
  final user = FirebaseAuth.instance.currentUser!;

  IconData _favIconOutlined = Icons.favorite_outline;

  final List<String> swipedRight;

  //HomeScreen1(List<String> swipedRight, {super.key});
  GameResultScreen({super.key, required this.swipedRight});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      onPanDown: (_) => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            titleSpacing: 10,
            title: const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text('DiaBeatThis!', style: DIABEATTHIS_LOGO),
            ),
          ),
          body: SafeArea(
              child: Column(
            children: [
              const SizedBox(height: 3),
              Flexible(
                  child: FirebaseAnimatedList(
                      query: ref.orderByChild('timestamp'),
                      defaultChild: const Text("Loading...", style: TEXT_PLAIN),
                      itemBuilder: (context, snapshot, animation, index) {
                        Object? tagsValues = snapshot.child('tags').value;
                        if (swipedRight.isNotEmpty &&
                            (snapshot.child("title").value.toString() ==
                                "tomato vegan test")) {
                          String tagString = tagsValues.toString();
                          List<String> tagsList = tagString
                              .substring(1, tagString.length - 1)
                              .split(", ");
                          var set =
                              Set.of(tagsList); //TODO: set of in one line?
                          if (set.containsAll(swipedRight)) {
                            return _buildPosts(context, snapshot, index);
                          }
                          //for(String element in swipedRight) {
                          // if (tagsValues
                          //    .toString()
                          //    .contains(element)) {
                          //return _buildPosts(context, snapshot, index);
                        }
                        //}
                        //}
                        return const SizedBox(); //TODO: add no results found
                      })),
            ],
          ))),
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
                  _buildCreator(context, snapshot, index),
                  //TODO: remove?
                  _buildTitle(context, snapshot, index),
                  _buildImage(context, snapshot, index),
                  _buildDescription(context, snapshot, index),
                  _buildCommentsAndLikes(context, snapshot, index),
                  //TODO: remove?
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
    //TODO: remove?
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
          snapshot.child('currentUser').value.toString(),
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
        IconButton(
          icon: const Icon(
            Icons.mode_comment_outlined,
            color: COLOR_INDIGO_LIGHT,
            size: 20,
          ),
          onPressed: () {
            //login screen if guest
            // FirebaseAuth.instance.currentUser!.isAnonymous
            //                         ? AuthScreen()
            //                         :
          },
        ),
        IconButton(
            icon: Icon(
              _favIconOutlined,
              color: COLOR_RED,
              size: 20,
            ),
            onPressed: () {
              //TODO: add new changes or remove likes and create route to post screen
              // FirebaseAuth.instance.currentUser!.isAnonymous
              //                         ? AuthScreen()
              //                         :
            })
      ],
    );
  }
}
