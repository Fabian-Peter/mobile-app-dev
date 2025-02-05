import 'dart:io';
import 'package:diabeatthis/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:diabeatthis/screens/home_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:uuid/uuid.dart';
import '../classes/utils.dart';

class CreateRecipeScreen extends StatefulWidget {
  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  //Firebase variables
  final database = FirebaseDatabase(
          databaseURL:
              "https://diabeathis-f8ee3-default-rtdb.europe-west1.firebasedatabase.app")
      .reference();
  String? query = FirebaseAuth.instance.currentUser?.uid.toString();
  final refUser = FirebaseDatabase.instance.ref('Users');
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  bool _isInAsyncCall = false;

  //TextController variables
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> ingredientsControllers = <TextEditingController>[
    TextEditingController()
  ];
  List<TextEditingController> ingredientsQuantityControllers =
      <TextEditingController>[TextEditingController()];
  TextEditingController descriptionController = TextEditingController();
  TextEditingController instructionController = TextEditingController();
  TextEditingController nutritionController = TextEditingController();

  //Page variables
  int fieldsNumber = 1;
  final formKey = GlobalKey<FormState>();

  //Image variables
  late String name;
  File? image;
  var uuid = Uuid();
  bool isImageMissing = false;

  //Tags variables
  final List<Text> _recipeTags1 = <Text>[
    const Text('Fish', style: TAGS_TOGGLE),
    const Text('Meat', style: TAGS_TOGGLE),
    const Text('Veggie', style: TAGS_TOGGLE),
    const Text('Vegan', style: TAGS_TOGGLE),
    const Text('Pasta', style: TAGS_TOGGLE),
  ];
  final List<Text> _recipeTags2 = <Text>[
    const Text('Rice', style: TAGS_TOGGLE),
    const Text('Gluten free', style: TAGS_TOGGLE),
    const Text('Dessert', style: TAGS_TOGGLE),
    const Text('Asian', style: TAGS_TOGGLE),
    const Text('Quick', style: TAGS_TOGGLE),
  ];
  final List<bool> _selectedTags1 = List.filled(5, false);
  final List<bool> _selectedTags2 = List.filled(5, false);
  bool isTagsMissing = false;

  Future pickImage(ImageSource source) async {
    setState(() {
      isImageMissing = false;
      return;
    });
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => this.image = imageTemporary);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<String> getUsername() async {
    DataSnapshot snapshot1 =
        await FirebaseDatabase.instance.ref('Users/$query/username').get();
    String username = await snapshot1.value.toString();
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
                  icon: const Icon(Icons.image, color: COLOR_INDIGO),
                  label: const Text('Gallery', style: TEXT_PLAIN_INDIGO),
                  onPressed: () => pickImage(ImageSource.gallery),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black),
                  icon: const Icon(Icons.camera_alt, color: COLOR_INDIGO),
                  label: const Text('Camera', style: TEXT_PLAIN_INDIGO),
                  onPressed: () => pickImage(ImageSource.camera),
                )
              ]));
        });
  }

  @override
  void dispose() {
    titleController.dispose();
    ingredientsControllers.clear();
    ingredientsQuantityControllers.clear();
    descriptionController.dispose();
    instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Create new Post', style: HEADLINE_BOLD_WHITE),
          ),
          body: ModalProgressHUD(
            inAsyncCall: _isInAsyncCall,
            // demo of some additional parameters
            opacity: 0.5,
            progressIndicator: const CircularProgressIndicator(),

            child: _buildForm(context),
          ),
        ));
  }

  Widget _buildForm(BuildContext context) {
    return Form(
        key: formKey,
        child: ListView(
          children: [
            if (image != null)
              Stack(clipBehavior: Clip.none, children: [
                Image.file(image!, height: 160, width: 400, fit: BoxFit.cover),
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
                      child: const Icon(Icons.camera_alt),
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
                      backgroundColor:
                          isImageMissing ? Colors.red : COLOR_INDIGO,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        _pictureEditBottomSheet(context);
                      },
                      child: const Icon(Icons.camera_alt),
                    )),
              ]),
            const SizedBox(
              height: 27,
            ),
            isImageMissing
                ? const Padding(
                    padding: EdgeInsets.only(left: 145.5),
                    child: Text("Missing image!",
                        style: TextStyle(color: Colors.red)))
                : const SizedBox(),
            _buildTitle(),
            _buildDescription(),
            Row(children: const [
              Padding(
                  padding: EdgeInsets.only(left: 8, top: 8),
                  child: Text("Amount", style: POST_CAPTION_INDIGO_LIGHT)),
              Padding(
                  padding: EdgeInsets.only(left: 17, top: 8),
                  child: Text("Ingredients", style: POST_CAPTION_INDIGO_LIGHT))
            ]),
            for (var i = 0; i < fieldsNumber; i++) _buildNewIngredientTile(i),
            _buildAddButton(),
            _buildInstructions(),
            _buildTagSelector(),
            isTagsMissing
                ? const Padding(
                    padding: EdgeInsets.only(left: 20, bottom: 8),
                    child: Text("Select at least one tag",
                        style: TextStyle(color: Colors.red, fontSize: 12)))
                : const SizedBox(),
            _buildNutritions(),
            _buildSubmitButton()
          ],
        ));
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
            padding: EdgeInsets.only(left: 8, top: 8),
            child: Text("Title", style: POST_CAPTION_INDIGO_LIGHT)),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(25),
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value!.isEmpty) {
                return "Enter Title";
              }
              return null;
            },
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
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
            padding: EdgeInsets.only(left: 8, top: 8),
            child: Text("Description", style: POST_CAPTION_INDIGO_LIGHT)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(150),
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value!.isEmpty) {
                return "Enter Username";
              }
              return null;
            },
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
                  color: COLOR_INDIGO_LIGHT,
                  width: 3.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewIngredientTile(int index) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
            width: 60,
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value!.isEmpty) {
                  return "";
                }
                return null;
              },
              controller: ingredientsQuantityControllers[index],
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
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
            )),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8, top: 8),
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Enter amount and ingredient";
                }
                return null;
              },
              controller: ingredientsControllers[index],
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Tasty ingredient',
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
            )),
      )
    ]);
  }

  Widget _buildAddButton() {
    return Row(children: [
      IconButton(
          icon: const Icon(Icons.add_circle_outline,
              color: COLOR_INDIGO_LIGHT, size: 30),
          onPressed: () {
            setState(() {
              fieldsNumber++;
              ingredientsQuantityControllers.add(TextEditingController());
              ingredientsControllers.add(TextEditingController());
            });
          }),
      const Padding(
          padding: EdgeInsets.only(left: 2, top: 2),
          child: Text("Add new ingredient",
              style: TextStyle(
                  color: COLOR_INDIGO_LIGHT,
                  fontSize: 14,
                  fontFamily: 'VisbyDemiBold')))
    ]);
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
            padding: EdgeInsets.only(left: 8, top: 8),
            child: Text("Instructions", style: POST_CAPTION_INDIGO_LIGHT)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value!.isEmpty) {
                return "Enter instructions";
              }
              return null;
            },
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
      ],
    );
  }

  Widget _buildTagSelector() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
          padding: EdgeInsets.only(left: 8, top: 8),
          child: Text("Tags", style: POST_CAPTION_INDIGO_LIGHT)),
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildToggleButtonRow(_selectedTags1, _recipeTags1)),
      Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8, right: 8),
          child: _buildToggleButtonRow(_selectedTags2, _recipeTags2))
    ]);
  }

  Widget _buildToggleButtonRow(List<bool> selectedTags, List<Text> recipeTags) {
    return ToggleButtons(
      direction: Axis.horizontal,
      onPressed: (int index) {
        setState(() {
          isTagsMissing = false;
        });
        // All buttons are selectable.
        setState(() {
          selectedTags[index] = !selectedTags[index];
        });
      },
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      borderColor: isTagsMissing ? Colors.red : COLOR_INDIGO_LIGHT,
      selectedBorderColor: COLOR_INDIGO,
      selectedColor: Colors.white,
      fillColor: COLOR_INDIGO,
      color: COLOR_INDIGO,
      constraints: BoxConstraints(
        minHeight: 40.0,
        minWidth: MediaQuery.of(context).size.width * 0.185,
      ),
      isSelected: selectedTags,
      children: recipeTags,
    );
  }

  Widget _buildNutritions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
          padding: EdgeInsets.only(left: 8, top: 8),
          child: Text("Nutritional Values", style: POST_CAPTION_INDIGO_LIGHT)),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value!.isEmpty) {
              return "Enter nutritions";
            }
            return null;
          },
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
      )
    ]);
  }

  Widget _buildSubmitButton() {
    return Padding(
        padding:
            const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 14),
        child: ElevatedButton(
            onPressed: () async {
              List<String> tagList = [];
              for (int i = 0; i < _selectedTags1.length; i++) {
                if (_selectedTags1[i]) {
                  tagList.add(_recipeTags1[i].data.toString());
                }
              }
              for (int i = 0; i < _selectedTags2.length; i++) {
                if (_selectedTags2[i]) {
                  tagList.add(_recipeTags2[i].data.toString());
                }
              }

              final isValid = formKey.currentState!.validate();
              if (image == null) {
                setState(() {
                  isImageMissing = true;
                  return;
                });
              }
              if (tagList.isEmpty) {
                setState(() {
                  isTagsMissing = true;
                });
              }
              if (!isValid) return;

              if (image != null && !isTagsMissing && !isImageMissing) {
                try {
                  setState(() {
                    _isInAsyncCall = true;
                  });

                  List<String> ingredientList = [];
                  for (var element in ingredientsControllers) {
                    ingredientList.add(element.text);
                  }

                  List<String> ingredientQuantityList = [];
                  for (var element in ingredientsQuantityControllers) {
                    ingredientQuantityList.add(element.text);
                  }

                  String imageURL = await uploadPicture(image!);

                  String timestamp = DateTime.now().toString();
                  var timeIdent = new DateTime.now().millisecondsSinceEpoch;
                  String username = await getUsername();
                  var myRef = database.child('post').push();
                  var key = myRef.key!;

                  final newRecipe = <String, dynamic>{
                    'likeAmount': 0,
                    'CommentsAmount': 0,
                    'happyAmount': 0,
                    'unhappyAmount': 0,
                    'bloodSugarAmount': 0,
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'ingredients': ingredientList,
                    'ingredientsQuantity': ingredientQuantityList,
                    'instructions': instructionController.text,
                    'tags': tagList,
                    'timestamp': timestamp,
                    'currentUser': username,
                    'pictureID': imageURL,
                    'nutrition': nutritionController.text,
                    'timeSorter': 0 - timeIdent!,
                    'reference': key
                  };
                  database
                      .child('post/$key')
                      .set(newRecipe)
                      .then((_) => print("call has been made"));

                  setState(() {
                    _isInAsyncCall = false;
                    fieldsNumber = 1;
                  });

                  Navigator.pop(context, true); //replaces dispose()

                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                } on FirebaseAuthException catch (e) {
                  print(e);

                  Utils.showSnackBar(e.message);
                }
              }
            },
            child: const Text('Post',
                style: TextStyle(fontFamily: "VisbyDemiBold", fontSize: 18))));
  }
}
