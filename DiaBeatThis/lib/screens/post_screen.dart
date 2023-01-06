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
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              _buildTextRow('Created at:',
                  "${post.creationDate.day}.${post.creationDate.month}.${post.creationDate.year}"),
              const SizedBox(height: 8),

              _buildTextRow('Posted by:', post.creator.name),
              const SizedBox(height: 8),

              _buildTextRow('Tags:', post.recipe.tags!.join(', ')),
              const SizedBox(height: 8),

              _buildTextRow('Nutrition:', post.recipe.nutrition!.join(', ')),
              const SizedBox(height: 25),

              Text(post.recipe.description, style: TEXT_PLAIN),
              const SizedBox(height: 35),

              Image.asset('assets/images/${post.recipe.title}.png'),
              //TODO: mit gespeichertem bild aus datenbank ersetzen
              const SizedBox(height: 25),

              const Text(
                "Ingredients:",
                style: TEXT_BOLD,
              ),
              const SizedBox(height: 15),

              _buildIngredients(post.recipe.ingredients),
              const SizedBox(height: 25),

              const Text(
                "Directions:",
                style: TEXT_BOLD,
              ),
              const SizedBox(height: 15),

              _buildGuide(post.recipe.directions),
              const SizedBox(height: 25),

              _buildTextRow('Comments:', post.comments?.first ?? "no comments"),
              //TODO
              const SizedBox(height: 8),

              _buildTextRow('Likes:', post.likes?.first.name ?? "no likes"),
              //TODO
              const SizedBox(height: 8),

              _buildTextRow(
                  'Reactions:', post.reactions?.toString() ?? "no reactions"),
              //TODO
            ],
          ),
        ),
      ),
    );
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

  Widget _buildIngredients(List<String> ingredients) {
    return Column(
      children: ingredients.map((ingredient) {
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
    );
  }

  Widget _buildGuide(List<String> directions) {
    return Column(
      children: directions.map((step) {
        return Row(children: [
          Text(
            "${directions.indexOf(step) + 1}.", //start from 1
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
    );
  }
}
