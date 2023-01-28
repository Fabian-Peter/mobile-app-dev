import 'package:diabeatthis/data/dummy_data.dart';
import 'package:diabeatthis/screens/auth_screen.dart';
import 'package:diabeatthis/screens/createRecipe_screen.dart';
import 'package:diabeatthis/screens/game_screen.dart';
import 'package:diabeatthis/screens/post_screen.dart';
import 'package:diabeatthis/screens/profile_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:diabeatthis/utils/constants.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cached_network_image/cached_network_image.dart';
import '../classes/Post.dart';
import '../classes/user.dart';
import 'package:badges/badges.dart';

import 'Comments_Screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.uid});

  final String? uid;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Firebase variables
  final ref = FirebaseDatabase.instance.ref("post");
  final user = FirebaseAuth.instance.currentUser!;
  final database = FirebaseDatabase(
          databaseURL:
              "https://diabeathis-f8ee3-default-rtdb.europe-west1.firebasedatabase.app")
      .reference();
  late Query query = ref.orderByChild('timeSorter');
  Key listKey = Key(DateTime.now().millisecondsSinceEpoch.toString());

  //Icon variables
  IconData icon = Icons.favorite_border_outlined;
  IconData _favIconOutlinedFilter = Icons.favorite_border_outlined;

  //Page variables
  TextEditingController searchController = TextEditingController();
  TextEditingController textController = TextEditingController();
  bool isVisible = false;

  //Searchbar variables
  FocusNode searchBarFocusNode = FocusNode();
  String searchWord = "";

  @override
  void initState() {
    super.initState();
  }

  //void getComments() async{
  //  DataSnapshot snippy = await FirebaseDatabase.instance.ref().orderByChild('comments').limitToFirst(3).get();
  //  print(snippy.value);
  //}

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
            actions: <Widget>[
              Row(
                children: [
                  _buildLogButton(context),
                  _buildProfileIcon(context)
                ],
              )
            ],
          ),
          body: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.forward) {
                  if (!isVisible) {
                    setState(() => isVisible = true);
                  }
                } else if (notification.direction == ScrollDirection.reverse) {
                  if (isVisible) {
                    setState(() => isVisible = false);
                  }
                } else if (notification.direction == ScrollDirection.reverse) {
                  if (isVisible) {
                    setState(() => isVisible = false);
                  }
                }
                return true;
              },
              child: SafeArea(
                  child: Column(
                children: [
                  const SizedBox(height: 3),
                  _buildSearchBar(context),
                  Flexible(
                      child: FirebaseAnimatedList(
                          query: ref.orderByChild('timeSorter'),
                          defaultChild:
                              const Text("Loading...", style: TEXT_PLAIN),
                          itemBuilder: (context, snapshot, animation, index) {
                            Object? ingredientsValues =
                                snapshot.child('ingredients').value;
                            Object? titleValue = snapshot.child('title').value;
                            if (searchWord != "") {
                              if (ingredientsValues
                                      .toString()
                                      .toLowerCase()
                                      .contains(searchWord) ||
                                  titleValue
                                      .toString()
                                      .toLowerCase()
                                      .contains(searchWord)) {
                                return _buildPosts(context, snapshot, index);
                              }
                            } else {
                              return _buildPosts(context, snapshot, index);
                            }
                            return const SizedBox();
                          })),
                ],
              ))),
          floatingActionButton: isVisible
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                        heroTag: "btn_game",
                        child: const Icon(Icons.restaurant_menu, size: 35),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) {
                              return FirebaseAuth
                                      .instance.currentUser!.isAnonymous
                                  ? AuthScreen()
                                  : GameScreen();
                            }),
                          );
                        }),
                    const SizedBox(height: 15),
                    FloatingActionButton(
                      heroTag: "btn_create",
                      child: const Icon(Icons.add, size: 35),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) {
                            return FirebaseAuth
                                .instance.currentUser!.isAnonymous
                                ? AuthScreen()
                                : CreateRecipeScreen();}),
                        );
                      }),
                  ],
                )
              : null,
        ));
  }

  Widget _buildLogButton(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 13),
        child: SizedBox(
            height: 28,
            width: 100,
            child: FloatingActionButton.extended(
                heroTag: "logButton",
                backgroundColor: COLOR_WHITE,
                label: FirebaseAuth.instance.currentUser!.isAnonymous
                    ? const Text("Login", style: LOGBUTTON)
                    : const Text("Logout", style: LOGBUTTON),
                icon: Icon(
                    FirebaseAuth.instance.currentUser!.isAnonymous
                        ? Icons.login
                        : Icons.logout,
                    size: 19.0,
                    color: COLOR_INDIGO),
                onPressed: () => FirebaseAuth.instance.signOut())));
  }

  Widget _buildProfileIcon(BuildContext context) {
//TODO: get current user datas and set image url
    return ClipRRect(
      borderRadius: BorderRadius.circular(PROFILE_ICON_BAR_SIZE / 2),
      child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            child: ClipRRect(
              //TODO: guest icon
              borderRadius: BorderRadius.circular(10),
              child: FirebaseAuth.instance.currentUser!.isAnonymous
                  ? Image.asset(
                      'assets/images/DefaultIcon.png',
                      height: PROFILE_ICON_BAR_SIZE,
                      width: PROFILE_ICON_BAR_SIZE,
                    )
                  : CachedNetworkImage(
                      height: PROFILE_ICON_BAR_SIZE,
                      width: PROFILE_ICON_BAR_SIZE,
                      imageUrl: "placeholder",
                      //url, //TODO: replace
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                    ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) {
                  return FirebaseAuth.instance.currentUser!.isAnonymous
                      ? AuthScreen()
                      : const ProfileScreen();
                }),
              );
            },
          )),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(children: [
          Expanded(
              child: SizedBox(
                  height: 33,
                  child: TextFormField(
                    focusNode: searchBarFocusNode,
                    onTap: () => searchBarFocusNode.requestFocus(),
                    controller: searchController,
                    onChanged: (text) {
                      setState(() {
                        if (searchController.text != "") {
                          searchWord = searchController.text.toLowerCase();
                        }
                      });
                    },
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.cancel,
                              color: COLOR_INDIGO_LIGHT),
                          iconSize: 15,
                          splashRadius: 20,
                          onPressed: () {
                            setState(() {
                              searchWord = "";
                            });
                            searchController.clear();
                            searchBarFocusNode.unfocus();
                          }),
                      labelText: 'Search for recipe or ingredient...',
                      labelStyle: const TextStyle(
                          fontFamily: "VisbyMedium",
                          fontSize: 14,
                          color: COLOR_INDIGO_LIGHT),
                      isDense: true,
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                        color: COLOR_INDIGO_LIGHT,
                      )),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: COLOR_INDIGO_LIGHT,
                          width: 3.0,
                        ),
                      ),
                    ),
                  ))),
          IconButton(
            icon: Icon(_favIconOutlinedFilter, color: COLOR_INDIGO_LIGHT),
            iconSize: 25,
            splashRadius: 20,
            onPressed: () {
              //TODO: show all liked posts for logged user
              // FirebaseAuth.instance.currentUser!.isAnonymous
              //                         ? AuthScreen()
              //                         :
              setState(() {
                if (_favIconOutlinedFilter == Icons.favorite_border_outlined) {
                  _favIconOutlinedFilter = Icons.favorite;
                } else {
                  _favIconOutlinedFilter = Icons.favorite_border_outlined;
                }
                if (searchController.text != "") {
                  listKey =
                      Key(DateTime.now().millisecondsSinceEpoch.toString());
                  query =
                      ref.orderByChild("title").equalTo(searchController.text);
                }
              });
              searchBarFocusNode.unfocus();
            },
          ),
        ]));
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
    String url = snapshot
        .child('pictureID')
        .value
        .toString(); //TODO: get user image based on username

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(USER_ICON_POST_SIZE / 2),
              child: InkWell(
                child: CachedNetworkImage(
                  height: PROFILE_ICON_BAR_SIZE,
                  width: PROFILE_ICON_BAR_SIZE,
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
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
          badgeContent: Text(commentsAmount, style: TextStyle(color: Colors.white)),
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
              Text(likesAmount, style: TextStyle(color: Colors.white)),
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
