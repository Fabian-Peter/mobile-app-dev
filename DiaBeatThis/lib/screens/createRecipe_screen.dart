import 'dart:io';

import 'package:diabeatthis/screens/home_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CreateRecipeScreen extends StatefulWidget {
  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final database = FirebaseDatabase(
          databaseURL:
              "https://diabeathis-f8ee3-default-rtdb.europe-west1.firebasedatabase.app")
      .reference();
  File? image;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => this.image = imageTemporary);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

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
      body: ListView(
        children: [
          if (image != null)
            Image.file(image!, width: 160, height: 160, fit: BoxFit.cover)
          else
            Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Blue_circle_for_diabetes.svg/375px-Blue_circle_for_diabetes.svg.png',
                height: 160,
                width: 160,
                fit: BoxFit.cover),
          //Hier könnte Ihr Logo stehen!
          const SizedBox(
            height: 24,
          ),
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
          FloatingActionButton(
            heroTag: "btn1",
            child: Icon(Icons.camera_alt),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            onPressed: () => pickImage(ImageSource.camera),
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
    );
  }
}
