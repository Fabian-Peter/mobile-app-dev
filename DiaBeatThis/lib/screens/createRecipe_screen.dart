import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:diabeatthis/screens/home_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:uuid/uuid.dart';

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
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  var uuid = Uuid();



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

  Future<void> uploadPicture (File file) async {
    String name = uuid.v1().toString();
    try {
      await storage.ref('image/$name').putFile(file);
    }
    on firebase_core.FirebaseException catch (e) {
      print(e) {
        print(e);
      }
    }
  }



  void _pictureEditBottomSheet(context) {
    showModalBottomSheet(
        context: context, builder: (BuildContext bc) {
      return SizedBox(
          height: 110,

          child: ListView(
          children: [
            ElevatedButton.icon(style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: Colors.black),
              icon: Icon(Icons.image),
              onPressed: () => pickImage(ImageSource.gallery),
              label: Text('Gallery'),
            ),
            ElevatedButton.icon(style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: Colors.black),
              onPressed: () => pickImage(ImageSource.camera),
              icon: Icon(Icons.camera_alt),
              label: Text('Camera'),

            )
          ]
      )
      );}
    );
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
            onPressed: () {
              _pictureEditBottomSheet(context);
            },
          ),

          ElevatedButton(
              onPressed: () {
                uploadPicture(image!);
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
