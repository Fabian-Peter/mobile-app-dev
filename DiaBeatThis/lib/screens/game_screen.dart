import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:diabeatthis/screens/home_screen.dart';
import 'package:diabeatthis/screens/post_screen.dart';
import 'package:diabeatthis/screens/profile_screen.dart';
import 'package:diabeatthis/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:swipe_cards/swipe_cards.dart';

import 'Comments_Screen.dart';
import 'auth_screen.dart';

class GameScreen extends StatefulWidget {
  GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;

  final List<String> _names = [
    "Fish",
    "Meat",
    "Veggie",
    "Vegan",
    "Pasta",
    "Rice",
    "Gluten free",
    "Dessert",
    "Asian",
    "Quick"
  ];

  final List<String> _images = [
    "assets/images/Fish.png",
    "assets/images/Meat.png",
    "assets/images/Vegetarian.png",
    "assets/images/Vegan.png",
    "assets/images/Pasta.png",
    "assets/images/Rice.png",
    "assets/images/Glutenfree.png",
    "assets/images/Dessert.png",
    "assets/images/Asian.png",
    "assets/images/QuickEasy.png"
  ];

  final List<String> swipedRight = [];

  @override
  void initState() {
    for (int i = 0; i < _names.length; i++) {
      _swipeItems.add(SwipeItem(
          content: Content(text: _names[i], image: _images[i]),
          likeAction: () {
            swipedRight.add(_names[i]);
          }));
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tinder",
              style: TextStyle(fontFamily: "VisbyDemiBold")),
        ),
        body: Center(
            child: Column(
          children: [
            const SizedBox(height: 50),
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 6,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image:
                                  AssetImage(_swipeItems[index].content.image),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Implement the stroke
                              Text(
                                _swipeItems[index].content.text,
                                style: TextStyle(
                                  fontSize: 37,
                                  letterSpacing: 5,
                                  fontFamily: 'VisbyDemiBold',
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 8
                                    ..color = Colors.black26,
                                ),
                              ),
                              // The text inside
                              Text(
                                _swipeItems[index].content.text,
                                style: const TextStyle(
                                    fontSize: 37,
                                    letterSpacing: 5,
                                    fontFamily: 'VisbyDemiBold',
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                      onStackFinished: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    GameResultScreen(swipedRight: swipedRight)),
                            (Route<dynamic> route) => false);
                      },
                      leftSwipeAllowed: true,
                      rightSwipeAllowed: true,
                      upSwipeAllowed: false,
                      fillSpace: true,
                    ),
                  ),
                ])),
            Padding(
              padding: const EdgeInsets.only(top: 25),
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
            )
          ],
        )));
  }
}

class Content {
  final String text;
  final String image;

  Content({required this.text, required this.image});
}

class GameResultScreen extends StatefulWidget {
  final List<String> swipedRight;

  const GameResultScreen({super.key, required this.swipedRight});

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  //Firebase variables
  final ref = FirebaseDatabase.instance.ref("post");
  final user = FirebaseAuth.instance.currentUser!;
  final database = FirebaseDatabase.instance.refFromURL(
      "https://diabeathis-f8ee3-default-rtdb.europe-west1.firebasedatabase.app");

  IconData icon = Icons.favorite_border_outlined;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      onPanDown: (_) => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
              titleSpacing: 10,
              title: const Text("Results",
                  style: TextStyle(fontFamily: "VisbyDemiBold")),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: COLOR_WHITE,
                  size: 24,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                      (Route<dynamic> route) => false);
                },
              )),
          body: SafeArea(
              child: Column(
            children: [
              const SizedBox(height: 3),
              Flexible(
                  child: FirebaseAnimatedList(
                      query: ref.orderByChild('timestamp'),
                      defaultChild: const Text("Loading...", style: TEXT_PLAIN),
                      itemBuilder: (context, snapshot, animation, index) {
                        if (widget.swipedRight.isNotEmpty) {
                          List<String> tagsList = [];
                          int tagsLength =
                              snapshot.child('tags').children.length;
                          for (int i = 0; i < tagsLength; i++) {
                            tagsList.add(snapshot
                                .child('tags')
                                .child(i.toString())
                                .value
                                .toString());
                          }
                          Set<String> set = Set.of(tagsList);
                          if (set.containsAll(widget.swipedRight)) {
                            return _buildPosts(context, snapshot, index);
                          }
                        }
                        return const SizedBox();
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
                  _buildTitle(context, snapshot, index),
                  _buildImage(context, snapshot, index),
                  _buildDescription(context, snapshot, index),
                  _buildComments(context, snapshot, index),
                  _buildLikes(context, snapshot, index),
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
          child: UserNameToID(
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
                child: UserProfileImage(userID: userID),
              );
            },
          ),
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
            style: HEADLINE_BOLD_BLACK),
      ),
    );
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
            style: TEXT_PLAIN),
      ),
    );
  }

  Widget _buildComments(
      BuildContext context, DataSnapshot snapshot, int index) {
    return Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          //Text(snapshot.hasChild('hello world').toString())
        ]));
  }

  Widget _buildLikes(BuildContext context, DataSnapshot snapshot, int index) {
    String ref = snapshot.child('reference').value.toString();
    String ownName = FirebaseAuth.instance.currentUser!.uid;
    var likesAmount = snapshot.child('likeAmount').value.toString();
    var commentsAmount = snapshot.child('CommentsAmount').value.toString();
    if (snapshot.child('likes/$ownName').value.toString() == 'true') {
      print('working until here');
    }
    //if(snapshot.child('likes/$ownName').value.toString().contains('true')){
    //  print(snapshot.child('likes/$ownName').value.toString());
    //  print('working');
    //  icon == Icons.favorite;
    //}

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Badge(
          borderRadius: BorderRadius.circular(8),
          position: BadgePosition.topEnd(top: 1, end: -3),
          badgeColor: COLOR_INDIGO_LIGHT,
          badgeContent:
              Text(commentsAmount, style: const TextStyle(color: Colors.white)),
          child: IconButton(
              icon: const Icon(
                Icons.comment_bank_sharp,
                color: COLOR_INDIGO_LIGHT,
                size: 20,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) {
                      return CommentsScreen(post: snapshot);
                    },
                  ),
                );
              })),
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
          ))
    ]);
  }
}
