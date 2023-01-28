import 'package:diabeatthis/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'auth_screen.dart';

class CommentsScreen extends StatefulWidget {
  final DataSnapshot post;

  CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.post.child('title').value.toString()+' Comments',
                style: HEADLINE_BOLD_WHITE),
            actions: <Widget>[_buildProfileIcon(context)]),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: _buildComments(context),
          ),
        ));
  }
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
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) {
                  return FirebaseAuth.instance.currentUser!.isAnonymous
                      ? AuthScreen()
                      : const ProfileScreen();
                }),
              );
            })),
  );
}

Widget _buildComments(context) {
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
                //_buildCommenter(context, snapshot, index),
                //TODO: tags icons
                //TODO: reactions
              ],
            ),
          ),
        ),
      ));
}

