import 'package:diabeatthis/screens/home_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class CreateRecipeScreen extends StatefulWidget {
  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final database = FirebaseDatabase(
          databaseURL:
              "https://diabeathis-f8ee3-default-rtdb.europe-west1.firebasedatabase.app")
      .reference();

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController ingredientsController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    @override
    void dispose() {
      titleController.dispose();
      ingredientsController.dispose();
      descriptionController.dispose();
      super.dispose();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Recipe'),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Column(
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'title'),
            ),
            TextFormField(
              controller: ingredientsController,
              keyboardType: TextInputType.multiline,
              maxLines: null, //Endlessly writable
              decoration: InputDecoration(labelText: 'ingredients'),
            ),
            TextFormField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(labelText: 'description'),
            ),
            ElevatedButton(
                onPressed: () {
                  final newRecipe = <String, dynamic>{
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'ingredients': ingredientsController.text
                  };

                  database
                      .child('recipes')
                      .push()
                      .set(newRecipe)
                      .then((_) => print("call has been made"));
                  dispose();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: Text('Submit'))
          ],
        ),
      )),
    );
  }
}
