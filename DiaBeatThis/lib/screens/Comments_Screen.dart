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
  FocusNode commentFocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String path = widget.post.child('reference').value.toString();
    String ownName = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseDatabase.instance.ref("post/$path/comments");
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            appBar: AppBar(
              title: Text('${widget.post.child('title').value} Comments',
                  style: HEADLINE_BOLD_WHITE),
              actions: <Widget>[
                Row(
                  children: [_buildProfileIcon(context)],
                ),
              ],
            ),
            body: SafeArea(
                child: Column(children: [
              Flexible(
                  child: FirebaseAnimatedList(
                      query: ref.orderByKey(),
                      defaultChild: const Text("Loading...", style: TEXT_PLAIN),
                      itemBuilder: (context, snapshot, animation, index) {
                        return _buildComments(context, snapshot, index);
                      })),
              if (!FirebaseAuth.instance.currentUser!.isAnonymous)
                _buildCommentTextField(context)
            ]))));
  }

  Widget _buildCommentTextField(BuildContext context) {
    String ownName = FirebaseAuth.instance.currentUser!.uid;
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Form(
            key: formKey,
            child: TextFormField(
                focusNode: commentFocusNode,
                onTap: () => commentFocusNode.requestFocus(),
                controller: commentsController,
                decoration: InputDecoration(
                  errorStyle: const TextStyle(height: 0),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: COLOR_INDIGO),
                    iconSize: 25,
                    splashRadius: 20,
                    onPressed: () async {
                      if (commentsController.text == "") {
                        return;
                      } else {
                        DataSnapshot snap = await FirebaseDatabase.instance
                            .ref('Users/$ownName')
                            .get();
                        String username =
                            snap.child('username').value.toString();
                        String postID =
                            widget.post.child('reference').value.toString();
                        String comment = commentsController.text;
                        var timeIdent =
                            new DateTime.now().millisecondsSinceEpoch;
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
                        commentFocusNode.unfocus();
                      }
                    },
                  ),
                  labelText: 'Enter your comment...',
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
                ))));
  }

  Widget _buildProfileIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        child: UserProfileImage(
            userID: currentUser, iconSize: PROFILE_ICON_BAR_SIZE),
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
              border: Border.all(width: 1.5, color: COLOR_INDIGO_LIGHT),
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
                    padding: const EdgeInsets.all(7),
                    child: Row(
                      children: [
                        UserNameToID(
                          username: snapshot.child('user').value.toString(),
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
                                  userID: userID,
                                  iconSize: PROFILE_ICON_BAR_SIZE),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(
                          snapshot.child('user').value.toString(),
                          style: COMMENTS_USER,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(snapshot.child('comment').value.toString(),
                          style: TEXT_PLAIN))
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
