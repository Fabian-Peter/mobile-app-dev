import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CreateRecipeScreen extends StatefulWidget {
  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final database = FirebaseDatabase(databaseURL: "https://diabeathis-f8ee3-default-rtdb.europe-west1.firebasedatabase.app").reference();

  @override
  Widget build(BuildContext context) {
    final postRef = database.child('post/');

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Recipe'),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  postRef.set({
                    'description': 'Vanilla Pudding',
                    'instructions': 'Just boil water'
                  }).then((_) => print("call has been made"));
                },
                child: Text('Simple set'))
          ],
        ),
      )),
    );
  }
}
