import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:diabeatthis/screens/home_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:uuid/uuid.dart';
import 'package:textfield_tags/textfield_tags.dart';

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
  TextEditingController titleController = TextEditingController();
  TextEditingController ingredientsController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController instructionController = TextEditingController();
  TextfieldTagsController tagsController = TextfieldTagsController();
  TextEditingController nutritionController = TextEditingController();
  late String name;

  static const List<String> _pickTags = <String>[
    'Hearty',
    'Dessert',
    'Breakfast',
    'Indian',
    'Fish',
    'Snack',
    'Beef',
    'Pasta',
    'Chinese',
    'Western',
    'Bread',
    'Diet',
    'Spicy',
    'Sour',
    'Fruity'
  ];

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

  Future<void> uploadPicture(File file) async {
    name = uuid.v1().toString();
    try {
      await storage.ref('image/$name').putFile(file);
    } on firebase_core.FirebaseException catch (e) {
      print(e) {
        print(e);
      }
    }
  }

  void _pictureEditBottomSheet(context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: context,
        builder: (BuildContext bc) {
          return Container(
              height: 110,
              padding: EdgeInsets.only(left: 10, right: 10),
              child: ListView(children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black),
                  icon: Icon(Icons.image),
                  onPressed: () => pickImage(ImageSource.gallery),
                  label: Text('Gallery'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black),
                  onPressed: () => pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Camera'),
                )
              ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    @override
    void dispose() {
      titleController.dispose();
      ingredientsController.dispose();
      descriptionController.dispose();
      instructionController.dispose();
      tagsController.dispose();
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'The title of your awesome recipe',
                isDense: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 3.0,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'A short description of your dish',
                isDense: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 3.0,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: ingredientsController,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'All of the tasty ingredients go here',
                isDense: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 3.0,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: instructionController,
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Now tell us, how to make it',
                isDense: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 3.0,
                  ),
                ),
              ),
            ),
          ),
          TextFieldTags(
            textfieldTagsController: tagsController,
            initialTags: const [
              'Your Tags go here',
            ],
            textSeparators: [' ', ','],
            letterCase: LetterCase.normal,
            validator: (String tag) {
              if (tagsController.getTags!.contains(tag)) {
                return 'you already entered that';
              }
              return null;
            },
            inputfieldBuilder:
                (context, tec, fn, error, onChanged, onSubmitted) {
              return ((context, sc, tags, onTagDelete) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: tec,
                    focusNode: fn,
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 3.0,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 3.0,
                        ),
                      ),
                      helperText:
                          'Some tags to help the hungry find your recipe',
                      helperStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      labelText: 'Enter tags',
                      errorText: error,
                      prefixIcon: tags.isNotEmpty
                          ? SingleChildScrollView(
                              controller: sc,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  children: tags.map((String tag) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20.0),
                                    ),
                                    color: Colors.blue,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        child: Text(
                                          '#$tag',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        onTap: () {
                                          //print("$tag selected");
                                        },
                                      ),
                                      const SizedBox(width: 4.0),
                                      InkWell(
                                        child: const Icon(
                                          Icons.cancel,
                                          size: 14.0,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          onTagDelete(tag);
                                        },
                                      )
                                    ],
                                  ),
                                );
                              }).toList()),
                            )
                          : null,
                    ),
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                  ),
                );
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: nutritionController,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Nutritional Values',
                isDense: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 3.0,
                  ),
                ),
              ),
            ),
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

                List<String>? tagList = tagsController.getTags;
                List<String>? reactions;
                List<String>? comments;
                final newRecipe = <String, dynamic>{
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'ingredients': ingredientsController.text,
                  'instructions': instructionController.text,
                  'tags': tagList,
                  //'reactions' : reactions,
                  //'comments' : comments,
                  'timestamp': DateTime.now().toString(),
                  'currentUser': FirebaseAuth.instance.currentUser?.uid,
                  'pictureID': name,
                  'nutrition': nutritionController.text
                };
                database
                    .child('post')
                    .push()
                    .set(newRecipe)
                    .then((_) => print("call has been made"));

                //.child(uniqueUserID).push(comment)
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
