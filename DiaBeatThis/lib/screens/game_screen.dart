import 'package:diabeatthis/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';

class GameScreen extends StatefulWidget {
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
  ];

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
  ];


  @override
  void initState() { //TODO: add tags to list?
    for (int i = 0; i < _names.length; i++) {
      _swipeItems.add(SwipeItem(
          content: Content(text: _names[i], image: _images[i]),
          likeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Liked ${_names[i]}"),
              duration: const Duration(milliseconds: 500),
            ));
          },
          nopeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Nope ${_names[i]}"),
              duration: const Duration(milliseconds: 500),
            ));
          },
          onSlideUpdate: (SlideRegion? region) async {
            print("Region $region");
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
                const SizedBox(height: 30),
                SizedBox(
                    width: 300,
                    height: 500,
                    child: Stack(children: [
                      SizedBox(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height - kToolbarHeight,
                        child: SwipeCards(
                          matchEngine: _matchEngine!,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        _swipeItems[index].content.image),
                                    fit: BoxFit.fill,
                                  )),
                              child: Text(
                                _swipeItems[index].content.text,
                                style: const TextStyle(fontSize: 50, fontFamily: 'VisbyDemiBold', color: Colors.white),
                              ),
                            );
                          },
                          onStackFinished: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Stack Finished"),
                                  duration: Duration(milliseconds: 500),
                                ));
                          },
                          itemChanged: (SwipeItem item, int index) {
                            print("item: ${item.content.text}, index: $index");
                          },
                          leftSwipeAllowed: true,
                          rightSwipeAllowed: true,
                          upSwipeAllowed: false,
                          fillSpace: true,
                          likeTag: Container(
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.green)
                            ),
                            child: const Text('Like'),
                          ),
                          nopeTag: Container(
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.red)
                            ),
                            child: const Text('Nope'),
                          ),
                        ),
                      ),
                    ])),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
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
                )
              ],
            )
        ));
  }
}

class Content {
  final String text;
  final String image;

  Content({required this.text, required this.image});
}