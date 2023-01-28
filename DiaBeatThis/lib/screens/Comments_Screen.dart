import 'package:diabeatthis/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class CommentsScreen extends StatefulWidget {
  final DataSnapshot post;

  CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final database = FirebaseDatabase.instance.refFromURL(
      "https://diabeathis-f8ee3-default-rtdb.europe-west1.firebasedatabase.app");
  TextEditingController commentsController = TextEditingController();
  String currentUser = FirebaseAuth.instance.currentUser!.uid.toString();

  @override
  Widget build(BuildContext context) {
    String path = widget.post.child('reference').value.toString();
    print(path);
    String ownName = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseDatabase.instance.ref("post/$path/comments");
    return Scaffold(
        appBar: AppBar(
            title: Text(
                widget.post.child('title').value.toString() + ' Comments',
                style: HEADLINE_BOLD_WHITE),
            actions: <Widget>[_buildProfileIcon(context)]),
        body: SafeArea(
            child: Column(children: [
          Flexible(
              child: FirebaseAnimatedList(
                  query: ref.orderByKey(),
                  defaultChild: const Text("Loading...", style: TEXT_PLAIN),
                  itemBuilder: (context, snapshot, animation, index) {
                    return _buildComments(context, snapshot, index);
                  })),
          Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: TextField(
                  controller: commentsController,
                  decoration: const InputDecoration(
                    labelText: 'Your Comment goes here',
                    labelStyle: TextStyle(
                        fontFamily: "VisbyMedium",
                        fontSize: 14,
                        color: COLOR_INDIGO_LIGHT),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: COLOR_INDIGO_LIGHT,
                    )),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: COLOR_INDIGO_LIGHT,
                        width: 3.0,
                      ),
                    ),
                  ))),
          Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: ElevatedButton(
                  onPressed: () async {
                    DataSnapshot snap = await FirebaseDatabase.instance
                        .ref('Users/$ownName')
                        .get();
                    String username = snap.child('username').value.toString();
                    print(username);
                    String postID =
                        widget.post.child('reference').value.toString();
                    String comment = commentsController.text;
                    var timeIdent = new DateTime.now().millisecondsSinceEpoch;
                    var timeSorter = 0 - timeIdent;
                    final newComment = <String, dynamic>{
                      'user': username,
                      'comment': comment
                    };
                    database
                        .child('post/$postID/comments/$timeSorter')
                        .set(newComment);
                    database
                        .child('post/$postID/CommentsAmount')
                        .set(ServerValue.increment(1));
                    clearText();
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontFamily: "VisbyDemiBold", fontSize: 18),
                  ))),
        ])));
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

  Widget _buildComments(context, snapshot, index) {
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
                  Padding(
                    padding: EdgeInsets.all(3),
                    child: Row(
                      children: [
                        InkWell(
                          child: Image.asset(
                            'assets/images/Avatar.png', //TODO: replace with user image
                            height: USER_ICON_POST_SIZE,
                            width: USER_ICON_POST_SIZE,
                          ),
                          onTap: () {
                            //TODO: OPEN PROFILE
                          },
                        ),
                        SizedBox(width: 10),
                        Text(snapshot.child('user').value.toString(),
                            style: TextStyle(
                                color: COLOR_INDIGO_LIGHT,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(3),
                      child: Text(snapshot.child('comment').value.toString()))
                ],
              ),
            ),
          ),
        ));
  }

  void clearText() {
    commentsController.clear();
  }
}
