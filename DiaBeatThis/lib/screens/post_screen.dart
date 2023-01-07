import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:diabeatthis/utils/constants.dart';

import '../classes/Post.dart';

class PostScreen extends StatelessWidget {
  final Post post;

  PostScreen({required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(post.recipe.title, style: HEADLINE_BOLD_WHITE),
            actions: <Widget>[_buildProfileIcon(context)]),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: _buildPost(context),
          ),
        ));
  }

  Widget _buildPost(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 7,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCreatorRow(context),
            _buildDescription(context),
            _buildContainerCaption(context, _buildNutrition(), 'Nutrition'),
            _buildImage(context),
            _buildContainerCaption(
                context, _buildIngredients(context), 'Ingredients'),
            _buildContainerCaption(
                context, _buildGuide(context), 'Instructions'),
            _buildCommunity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(post.recipe.description, style: TEXT_PLAIN));
  }

  Widget _buildNutrition() {
    const double iconSize = 54;
    return Row(children: [
      const SizedBox(width: 43),
      Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(iconSize / 2),
          child: Image.asset(
            'assets/images/Fats.png',
            height: iconSize,
            width: iconSize,
          ),
        ),
        const SizedBox(height: 5),
        const Text("Fats: 5g", style: TEXT_PLAIN) //TODO: replace with post values
      ]),
      const SizedBox(width: 30),
      Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(iconSize / 2),
          child: Image.asset(
            'assets/images/Carbs.png',
            height: iconSize,
            width: iconSize,
          ),
        ),
        const SizedBox(height: 5),
        const Text("Carbs: 20g", style: TEXT_PLAIN) //TODO: replace with post values
      ]),
      const SizedBox(width: 30),
      Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(iconSize / 2),
          child: Image.asset(
            'assets/images/Proteins.png',
            height: iconSize,
            width: iconSize,
          ),
        ),
        const SizedBox(height: 5),
        const Text("Proteins: 13g", style: TEXT_PLAIN) //TODO: replace with post values
      ])
    ]);
  }

  Widget _buildCreatorRow(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
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
          ),
        ),
        const SizedBox(width: 10),
        Text(
          post.creator.name,
          style: HOME_POST_CREATOR,
        ),
        const SizedBox(width: 160),
        const Icon(Icons.calendar_month_rounded, size: 13),
        const SizedBox(width: 5),
        Text(
            "${post.creationDate.day}.${post.creationDate.month}.${post.creationDate.year}",
            style: TEXT_BOLD)
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(
          top: 20,
        ),
        child: AspectRatio(
          aspectRatio: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('assets/images/${post.recipe.title}.png',
                //TODO: mit gespeichertem bild aus datenbank ersetzen
                fit: BoxFit.fill),
          ),
        ));
  }

  Widget _buildCommunity(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            _buildTextRow('Comments:', post.comments?.first ?? "no comments"),
            _buildTextRow('Likes:', post.likes?.first.name ?? "no likes"),
            _buildTextRow(
                'Reactions:', post.reactions?.toString() ?? "no reactions"),
          ],
        ));
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
                //TODO: open profile instead
              })),
    );
  }

  Widget _buildTextRow(String key, String value) {
    return Row(
      children: [
        Text(
          key,
          style: TEXT_BOLD,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TEXT_PLAIN,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildContainerCaption(
      BuildContext context, Widget widget, String caption) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Stack(
        children: <Widget>[
          Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              //width: 400,
              decoration: BoxDecoration(
                  color: COLOR_WHITE,
                  border: Border.all(width: 3, color: COLOR_INDIGO_LIGHT),
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: 5, top: 5, right: 5, bottom: 5),
                  child: Column(
                    children: [
                      widget,
                    ],
                  ))),
          Positioned(
              left: 30,
              top: 0,
              child: Container(
                padding:
                    const EdgeInsets.only(bottom: 2, top: 2, left: 7, right: 7),
                color: COLOR_WHITE,
                child: Text(
                  caption,
                  style: POST_CAPTION_INDIGO_LIGHT,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildIngredients(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          children: post.recipe.ingredients.map((ingredient) {
            return Row(children: [
              const Text(
                "\u2022",
                style: TEXT_BOLD,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  ingredient,
                  style: TEXT_PLAIN,
                ),
              )
            ]);
          }).toList(),
        ));
  }

  Widget _buildGuide(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          children: post.recipe.directions.map((step) {
            return Row(children: [
              Text(
                "${post.recipe.directions.indexOf(step) + 1}.", //start from 1
                style: TEXT_BOLD,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  step,
                  style: TEXT_PLAIN,
                ),
              )
            ]);
          }).toList(),
        ));
  }
}
