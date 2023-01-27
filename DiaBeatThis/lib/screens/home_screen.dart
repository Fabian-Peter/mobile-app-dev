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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.uid});

  final String? uid;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ref = FirebaseDatabase.instance.ref("post");
  final user = FirebaseAuth.instance.currentUser!;

  TextEditingController searchController = TextEditingController();
  FocusNode searchBarFocusNode = FocusNode();
  String searchWord = "";

  IconData _favIconOutlined = Icons.favorite_outline;
  IconData _favIconOutlinedFilter = Icons.favorite_outline;
  TextEditingController textController = TextEditingController();
  bool isVisible = false;
  List<Post>? posts = DummyData().returnData;
  User userTest = DummyData().user1;
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  late Future<String> dataFuture;

  @override
  void initState() {
    super.initState();
  }

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
                          query: ref.orderByChild('timestamp'),
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GameScreen()));
                      },
                    ),
                    const SizedBox(height: 15),
                    FloatingActionButton(
                      heroTag: "btn_create",
                      child: const Icon(Icons.add, size: 35),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateRecipeScreen()));
                      },
                    )
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
    final User profile = userTest;
    return ClipRRect(
      borderRadius: BorderRadius.circular(PROFILE_ICON_BAR_SIZE / 2),
      child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            child: Image.asset(
              //TODO: if guest, then show anonymous profile icon
              'assets/images/Profile.png',
              //TODO: replace with user image
              height: PROFILE_ICON_BAR_SIZE,
              width: PROFILE_ICON_BAR_SIZE,
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
            //TODO: open profile instead or login screen
            // FirebaseAuth.instance.currentUser!.isAnonymous
            //                         ? AuthScreen()
            //                         :
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
                if (_favIconOutlinedFilter == Icons.favorite_outline) {
                  _favIconOutlinedFilter = Icons.favorite;
                } else {
                  _favIconOutlinedFilter = Icons.favorite_outline;
                }
              });
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
                  _buildCommentsAndLikes(context, snapshot, index),
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
            //TODO: individual likes for posts and users or login screen
            // FirebaseAuth.instance.currentUser!.isAnonymous
            //                         ? AuthScreen()
            //                         :
            setState(() {
              if (_favIconOutlined == Icons.favorite_outline) {
                _favIconOutlined = Icons.favorite;
              } else {
                _favIconOutlined = Icons.favorite_outline;
              }
            });
          },
        )
      ],
    );
  }
}
