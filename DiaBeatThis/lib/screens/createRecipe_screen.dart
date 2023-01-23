import 'dart:io';
import 'package:diabeatthis/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:diabeatthis/screens/home_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
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
  final refUser = FirebaseDatabase.instance.ref('Users');
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
  bool _isInAsyncCall = false;
  String? query = FirebaseAuth.instance.currentUser?.uid.toString();







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

  Future<String>getUsername() async {
    DataSnapshot snapshot1 =   await FirebaseDatabase.instance.ref('Users/$query/username').get();
    String username = await snapshot1.value.toString();
    print (username);
    return username;
  }

  Future<String> uploadPicture(File file) async {


    name = uuid.v1().toString();
    var storeImage =
        firebase_storage.FirebaseStorage.instance.ref().child('image/$name');
    firebase_storage.UploadTask task1 = storeImage.putFile(file);
    String imageURL = await (await task1).ref.getDownloadURL();

    return imageURL;
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
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: ListView(children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black),
                  icon: const Icon(Icons.image),
                  onPressed: () => pickImage(ImageSource.gallery),
                  label: const Text('Gallery'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black),
                  onPressed: () => pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
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
        title: const Text('Create new Post', style: HEADLINE_BOLD_WHITE),
      ),
    body: ModalProgressHUD(
      inAsyncCall: _isInAsyncCall,
      // demo of some additional parameters
      opacity: 0.5,
      progressIndicator: CircularProgressIndicator(),

          child: _buildForm(context),
        ),


    );
  }

    Widget _buildForm(context){
      return ListView(
          children: [
            if (image != null)
              Stack(clipBehavior: Clip.none, children: [
                Image.file(image!, height: 160, width: 400, fit: BoxFit.cover),
                Positioned(
                    top: 120,
                    left: 165,
                    child: FloatingActionButton(
                      heroTag: "btn1",
                      child: Icon(Icons.camera_alt),
                      backgroundColor: COLOR_INDIGO,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        _pictureEditBottomSheet(context);
                      },
                    )),
              ])
            else
              Stack(clipBehavior: Clip.none, children: [
                Image.asset('assets/images/recipeCamera.png',
                    height: 160, width: 400, fit: BoxFit.cover),
                Positioned(
                    top: 120,
                    left: 165,
                    child: FloatingActionButton(
                      heroTag: "btn1",
                      backgroundColor: COLOR_INDIGO,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        _pictureEditBottomSheet(context);
                      },
                      child: Icon(Icons.camera_alt),
                    )),
              ]),
            //Hier könnte Ihr Logo stehen!
            const SizedBox(
              height: 30,
            ),
            const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text("Title", style: POST_CAPTION_INDIGO_LIGHT)),
            Padding(
              padding: const EdgeInsets.all(9.0),
              child: TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'The title of your recipe',
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
                ),
              ),
            ),
            const Padding(
                padding: EdgeInsets.only(left: 8, top: 8),
                child: Text("Description", style: POST_CAPTION_INDIGO_LIGHT)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'A short description of your dish',
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
                      color: Colors.blue,
                      width: 3.0,
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
                padding: EdgeInsets.only(left: 8, top: 8),
                child: Text("Ingredients", style: POST_CAPTION_INDIGO_LIGHT)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: ingredientsController,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'All of the tasty ingredients',
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
                ),
              ),
            ),
            const Padding(
                padding: EdgeInsets.only(left: 8, top: 8),
                child: Text("Instructions", style: POST_CAPTION_INDIGO_LIGHT)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: instructionController,
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Now tell us, how to make it...',
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
                ),
              ),
            ),
            const Padding(
                padding: EdgeInsets.only(left: 8, top: 8),
                child: Text("Tags", style: POST_CAPTION_INDIGO_LIGHT)),
            TextFieldTags(
              textfieldTagsController: tagsController,
              initialTags: const [
                'Your tags',
              ],
              textSeparators: [' ', ','],
              letterCase: LetterCase.normal,
              validator: (String tag) {
                if (tagsController.getTags!.contains(tag)) {
                  return 'You already entered that';
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
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: COLOR_INDIGO_LIGHT,
                            width: 3.0,
                          ),
                        ),
                        helperText:
                        'Some tags to help the hungry find your recipe',
                        helperStyle: const TextStyle(
                            color: COLOR_INDIGO, fontFamily: "VisbyMedium"),
                        labelText: 'Enter tags',
                        labelStyle: const TextStyle(
                            fontFamily: "VisbyMedium",
                            fontSize: 14,
                            color: COLOR_INDIGO_LIGHT),
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
                                    color: COLOR_INDIGO,
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
            const Padding(
                padding: EdgeInsets.only(left: 8, top: 8),
                child:
                Text("Nutritional Values", style: POST_CAPTION_INDIGO_LIGHT)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: nutritionController,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Fat, Carbs, Protein & Sugar',
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
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, bottom: 10, top: 14),
                child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isInAsyncCall = true;
                      });
                      //TODO add loading animation
                      String imageURL = await uploadPicture(image!);

                      List<String>? tagList = tagsController.getTags;
                      List<String>? reactions;
                      List<String>? comments;
                      String timestamp = DateTime.now().toString();
                      var timeIdent = new DateTime.now().millisecondsSinceEpoch;
                      String username = await getUsername();

                      final newRecipe = <String, dynamic>{
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'ingredients': ingredientsController.text,
                        'instructions': instructionController.text,
                        'tags': tagList,
                        //'reactions' : reactions,
                        //'comments' : comments,
                        'timestamp': timestamp,
                        'currentUser': username,
                        'pictureID': imageURL,
                        'nutrition': nutritionController.text,
                        'timeSorter' : 0-timeIdent!
                      };
                      database
                          .child('post')
                          .push()
                          .set(newRecipe)
                          .then((_) => print("call has been made"));

                      //.child(uniqueUserID).push(comment)
                      setState(() {
                        _isInAsyncCall = false;
                      });
                      dispose();

                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomeScreen()));
                    },
                    child: const Text('Post',
                        style: TextStyle(
                            fontFamily: "VisbyDemiBold", fontSize: 18))))
          ],

      );
    }
  }


