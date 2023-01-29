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
import 'package:cached_network_image/cached_network_image.dart';

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
              children: [_buildLogButton(context), _buildProfileIcon(context)],
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
                      query: ref.orderByChild('timeSorter'),
                      defaultChild: const Text("Loading...", style: TEXT_PLAIN),
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
                            return FirebaseAuth
                                    .instance.currentUser!.isAnonymous
                                ? AuthScreen()
                                : CreateRecipeScreen();
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
                          return FirebaseAuth.instance.currentUser!.isAnonymous
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
                    : ProfileScreen(userID: currentUser);
              }),
            );
          },
        ),
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
              FirebaseAuth.instance.currentUser!.isAnonymous
                  ? Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return AuthScreen();
                    }))
                  : setState(() {
                      if (_favIconOutlinedFilter ==
                          Icons.favorite_border_outlined) {
                        _favIconOutlinedFilter = Icons.favorite;
                      } else {
                        _favIconOutlinedFilter = Icons.favorite_border_outlined;
                      }
                      if (searchController.text != "") {
                        listKey = Key(
                            DateTime.now().millisecondsSinceEpoch.toString());
                        query = ref
                            .orderByChild("title")
                            .equalTo(searchController.text);
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
            child: UserNameToID(
              username: snapshot.child('currentUser').value.toString(),
              builder: (context, snapshot) {
                final userID = snapshot.data;
                return InkWell(
                  child: UserProfileImage(userID: userID),
                  onTap: userID == null
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) {
                              return ProfileScreen(userID: userID);
                            }),
                          );
                        },
                );
              },
            ),
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
    var bloodSugarAmount = snapshot.child('bloodSugarAmount').value.toString();
    var happyAmount = snapshot.child('happyAmount').value.toString();
    var unhappyAmount = snapshot.child('unhappyAmount').value.toString();
    var commentsAmount = snapshot.child('CommentsAmount').value.toString();
    if (snapshot.child('likes/$ownName').value.toString() == 'true') {
      print('working until here');
    }
    //if(snapshot.child('likes/$ownName').value.toString().contains('true')){
    //  print(snapshot.child('likes/$ownName').value.toString());
    //  print('working');
    //  icon == Icons.favorite;
    //}

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Badge(
        borderRadius: BorderRadius.circular(8),
        position: BadgePosition.topEnd(top: 1, end: -3),
        badgeColor: Colors.red,
        badgeContent:
            Text(likesAmount, style: const TextStyle(color: Colors.white)),
        child: IconButton(
            icon: Icon(
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
              }
            }),
      ),
      Badge(
          borderRadius: BorderRadius.circular(8),
          position: BadgePosition.topEnd(top: 1, end: -1),
          badgeColor: Colors.red,
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
                //print(snapshot.child('likes/$ownName').value.toString());
                //print (result);
                if (result == 'true') {
                  database.child('post/$ref/bloodSugar/$ownName').set('false');
                  print('removed bloodSugar');
                  database
                      .child('post/$ref/bloodSugarAmount')
                      .set(ServerValue.increment(-1));
                  icon = Icons.favorite_border_outlined;
                  setState(() {});
                } else {
                  database.child('post/$ref/bloodSugar/$ownName').set('true');
                  database
                      .child('post/$ref/bloodSugarAmount')
                      .set(ServerValue.increment(1));
                  print('added bloodSugar');
                  icon = Icons.favorite;
                  setState(() {});
                }
              }
            },
          )),
      Badge(
          borderRadius: BorderRadius.circular(8),
          position: BadgePosition.topEnd(top: 1, end: -1),
          badgeColor: Colors.green,
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
                //print(snapshot.child('likes/$ownName').value.toString());
                //print (result);
                if (result == 'true') {
                  database.child('post/$ref/happy/$ownName').set('false');
                  print('removed happy');
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
                  print('added happy');
                  icon = Icons.favorite;
                  setState(() {});
                }
              }
            },
          )),
      Badge(
          borderRadius: BorderRadius.circular(1),
          position: BadgePosition.topEnd(top: 1, end: -1),
          badgeColor: COLOR_INDIGO_LIGHT,
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
                //print(snapshot.child('likes/$ownName').value.toString());
                //print (result);
                if (result == 'true') {
                  database.child('post/$ref/unhappy/$ownName').set('false');
                  print('removed unhappy');
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
                  print('added unhappy');
                  icon = Icons.favorite;
                  setState(() {});
                }
              }
            },
          )),
      Spacer(),
      Badge(
          borderRadius: BorderRadius.circular(8),
          position: BadgePosition.topEnd(top: 1, end: -1),
          badgeColor: COLOR_INDIGO_LIGHT,
          badgeContent:
              Text(commentsAmount, style: TextStyle(color: Colors.white)),
          child: IconButton(
              icon: const Icon(
                Icons.comment_rounded,
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
    ]);
  }
}

class UserProfileImage extends StatefulWidget {
  const UserProfileImage({Key? key, required this.userID}) : super(key: key);
  final String? userID;

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
    return CircleAvatar(
      child: StreamBuilder<String?>(
        stream: userPictureID,
        initialData: null,
        builder: (context, snapshot) {
          final picture = snapshot.data;
          if (picture == null) {
            return Image.asset(
              //TODO: if guest, then show anonymous profile icon
              'assets/images/Profile.png',
              //TODO: replace with user image
              height: PROFILE_ICON_BAR_SIZE,
              width: PROFILE_ICON_BAR_SIZE,
            );
          } else {
            return CachedNetworkImage(
              imageUrl: picture,
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
