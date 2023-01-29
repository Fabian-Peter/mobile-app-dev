import 'package:diabeatthis/screens/auth_screen.dart';
import 'package:diabeatthis/screens/createRecipe_screen.dart';
import 'package:diabeatthis/screens/game_screen.dart';
import 'package:diabeatthis/screens/post_screen.dart';
import 'package:diabeatthis/screens/profile_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diabeatthis/utils/constants.dart';
import 'package:flutter/rendering.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:badges/badges.dart';
import 'package:flutter/services.dart';

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
  final ref2 = FirebaseDatabase.instance.ref("Users");
  final user = FirebaseAuth.instance.currentUser!;
  final database = FirebaseDatabase.instance.refFromURL(
      "https://diabeathis-f8ee3-default-rtdb.europe-west1.firebasedatabase.app");
  late Query query = ref.orderByChild('timeSorter');
  Key listKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
  String currentUser = FirebaseAuth.instance.currentUser!.uid.toString();

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

  final streamAuth = FirebaseAuth.instance.authStateChanges();

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
    return StreamBuilder<User?>(
      stream: streamAuth,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong!"));
        } else if (!snapshot.hasData) {
          return AuthScreen();
        }
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
                ),
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
                          query: query,
                          key: listKey,
                          defaultChild: const Center(
                            child: SizedBox(
                              width: 60.0,
                              height: 60.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
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
                          }),
                    ),
                  ],
                ),
              ),
            ),
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
                                return GameScreen();
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
                                  : CreateRecipeScreen();
                            }),
                          );
                        },
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
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
            onPressed: () => FirebaseAuth.instance.signOut()),
      ),
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

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(children: [
          Expanded(
              child: SizedBox(
                  height: 33,
                  child: TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(17),
                    ],
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
              String ownName = FirebaseAuth.instance.currentUser!.uid;
              FirebaseAuth.instance.currentUser!.isAnonymous
                  ? Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return AuthScreen();
                    }))
                  : setState(() {
                      if (_favIconOutlinedFilter ==
                          Icons.favorite_border_outlined) {
                        _favIconOutlinedFilter = Icons.favorite;
                        listKey = Key(
                            DateTime.now().millisecondsSinceEpoch.toString());
                        query =
                            ref.orderByChild('likes/$ownName').equalTo("true");
                      } else {
                        _favIconOutlinedFilter = Icons.favorite_border_outlined;
                        listKey = Key(
                            DateTime.now().millisecondsSinceEpoch.toString());
                        query = ref.orderByChild('timeSorter');
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
      ),
    );
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
                child: UserProfileImage(
                    userID: userID, iconSize: PROFILE_ICON_BAR_SIZE),
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
        child: Text(
          snapshot.child('title').value.toString(),
          style: HEADLINE_BOLD_BLACK,
        ),
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
              placeholder: (context, url) => const Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                  ),
                ),
              ),
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

  Widget _buildLikes(BuildContext context, DataSnapshot snapshot, int index) {
    String ref = snapshot.child('reference').value.toString();
    String ownName = FirebaseAuth.instance.currentUser!.uid;
    var likesAmount = snapshot.child('likeAmount').value.toString();
    var bloodSugarAmount = snapshot.child('bloodSugarAmount').value.toString();
    var happyAmount = snapshot.child('happyAmount').value.toString();
    var unhappyAmount = snapshot.child('unhappyAmount').value.toString();
    var commentsAmount = snapshot.child('CommentsAmount').value.toString();

    //if(snapshot.child('likes/$ownName').value.toString().contains('true')){
    //  print(snapshot.child('likes/$ownName').value.toString());
    //  print('working');
    //  icon == Icons.favorite;
    //}

    return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Badge(
            borderRadius: BorderRadius.circular(8),
            position: BadgePosition.topEnd(top: 1, end: 2),
            badgeColor: Colors.deepOrange,
            animationType: BadgeAnimationType.fade,
            badgeContent:
                Text(likesAmount, style: const TextStyle(color: Colors.white)),
            child: IconButton(
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.deepOrange,
                  size: 25,
                ),
                onPressed: () {
                  if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return AuthScreen();
                    }));
                  } else {
                    String result =
                        snapshot.child('likes/$ownName').value.toString();
                    if (result == 'true') {
                      database.child('post/$ref/likes/$ownName').set('false');
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
                      icon = Icons.favorite;
                      setState(() {});
                    }
                  }
                }),
          ),
          Badge(
              borderRadius: BorderRadius.circular(8),
              position: BadgePosition.topEnd(top: 1, end: 2),
              badgeColor: Colors.red,
              animationType: BadgeAnimationType.fade,
              badgeContent:
                  Text(bloodSugarAmount, style: TextStyle(color: Colors.white)),
              child: IconButton(
                icon: Icon(
                  Icons.format_color_reset,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: () {
                  if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return AuthScreen();
                    }));
                  } else {
                    String result =
                        snapshot.child('bloodSugar/$ownName').value.toString();
                    if (result == 'true') {
                      database
                          .child('post/$ref/bloodSugar/$ownName')
                          .set('false');
                      database
                          .child('post/$ref/bloodSugarAmount')
                          .set(ServerValue.increment(-1));
                      icon = Icons.favorite_border_outlined;
                      setState(() {});
                    } else {
                      database
                          .child('post/$ref/bloodSugar/$ownName')
                          .set('true');
                      database
                          .child('post/$ref/bloodSugarAmount')
                          .set(ServerValue.increment(1));
                      icon = Icons.favorite;
                      setState(() {});
                    }
                  }
                },
              )),
          Badge(
              borderRadius: BorderRadius.circular(8),
              position: BadgePosition.topEnd(top: 1, end: 2),
              badgeColor: Colors.green,
              animationType: BadgeAnimationType.fade,
              badgeContent:
                  Text(happyAmount, style: TextStyle(color: Colors.white)),
              child: IconButton(
                icon: Icon(
                  Icons.sentiment_very_satisfied_outlined,
                  color: Colors.green,
                  size: 20,
                ),
                onPressed: () {
                  if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return AuthScreen();
                    }));
                  } else {
                    String result =
                        snapshot.child('happy/$ownName').value.toString();
                    if (result == 'true') {
                      database.child('post/$ref/happy/$ownName').set('false');
                      database
                          .child('post/$ref/happyAmount')
                          .set(ServerValue.increment(-1));
                      icon = Icons.favorite_border_outlined;
                      setState(() {});
                    } else {
                      database.child('post/$ref/happy/$ownName').set('true');
                      database
                          .child('post/$ref/happyAmount')
                          .set(ServerValue.increment(1));
                      icon = Icons.favorite;
                      setState(() {});
                    }
                  }
                },
              )),
          Badge(
              borderRadius: BorderRadius.circular(1),
              position: BadgePosition.topEnd(top: 1, end: 2),
              badgeColor: COLOR_INDIGO_LIGHT,
              animationType: BadgeAnimationType.fade,
              badgeContent:
                  Text(unhappyAmount, style: TextStyle(color: Colors.white)),
              child: IconButton(
                icon: Icon(
                  Icons.sentiment_very_dissatisfied,
                  color: COLOR_INDIGO_LIGHT,
                  size: 20,
                ),
                onPressed: () {
                  if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return AuthScreen();
                    }));
                  } else {
                    String result =
                        snapshot.child('unhappy/$ownName').value.toString();
                    if (result == 'true') {
                      database.child('post/$ref/unhappy/$ownName').set('false');
                      database
                          .child('post/$ref/unhappyAmount')
                          .set(ServerValue.increment(-1));
                      icon = Icons.favorite_border_outlined;
                      setState(() {});
                    } else {
                      database.child('post/$ref/unhappy/$ownName').set('true');
                      database
                          .child('post/$ref/unhappyAmount')
                          .set(ServerValue.increment(1));
                      icon = Icons.favorite;
                      setState(() {});
                    }
                  }
                },
              )),
          Spacer(),
          Badge(
              borderRadius: BorderRadius.circular(8),
              position: BadgePosition.topEnd(top: 1, end: 1),
              badgeColor: COLOR_INDIGO,
              animationType: BadgeAnimationType.fade,
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
                          return CommentsScreen(post: snapshot);
                        },
                      ),
                    );
                  })),
        ]));
  }
}

class UserProfileImage extends StatefulWidget {
  const UserProfileImage(
      {Key? key, required this.userID, required this.iconSize})
      : super(key: key);
  final String? userID;
  final double iconSize;

  @override
  State<UserProfileImage> createState() => _UserProfileImageState();
}

class _UserProfileImageState extends State<UserProfileImage> {
  late Stream<String?> userPictureID;

  @override
  void initState() {
    userPictureID = getUserPictureID();
    super.initState();
  }

  @override
  void didUpdateWidget(UserProfileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userID != widget.userID) {
      setState(() => userPictureID = getUserPictureID());
    }
  }

  Stream<String?> getUserPictureID() {
    return FirebaseDatabase.instance
        .ref('Users/${widget.userID}/userPictureID')
        .onValue
        .map((event) => event.snapshot.value?.toString());
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.iconSize / 2),
      child: StreamBuilder<String?>(
        stream: userPictureID,
        initialData: null,
        builder: (context, snapshot) {
          final picture = snapshot.data;
          if (picture == null) {
            return Image.asset(
              'assets/images/DefaultIcon.png',
              height: widget.iconSize,
              width: widget.iconSize,
              fit: BoxFit.cover,
            );
          } else {
            return CachedNetworkImage(
              imageUrl: picture,
              height: widget.iconSize,
              width: widget.iconSize,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class UserNameToID extends StatefulWidget {
  const UserNameToID({Key? key, required this.username, required this.builder})
      : super(key: key);
  final String username;
  final AsyncWidgetBuilder<String?> builder;

  @override
  State<UserNameToID> createState() => _UserNameToIDState();
}

class _UserNameToIDState extends State<UserNameToID> {
  late Stream<String?> userID;

  @override
  void initState() {
    userID = getUserID(widget.username);
    super.initState();
  }

  @override
  void didUpdateWidget(UserNameToID oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username) {
      setState(() => userID = getUserID(widget.username));
    }
  }

  Stream<String> getUserID(String username) {
    return FirebaseDatabase.instance.ref('Users').onValue.map(
          (event) => event.snapshot.children.firstWhere((element) {
            return element.child("username").value!.toString() == username;
          }).key!,
        );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
        stream: userID, initialData: null, builder: widget.builder);
  }
}
