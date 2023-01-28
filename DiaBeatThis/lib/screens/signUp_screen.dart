import 'dart:io';
import 'package:diabeatthis/utils/constants.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../classes/utils.dart';
import '../main.dart';

class SignUpScreen extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpScreen({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
  //Firebase variables
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child("Users");
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  //Page variables
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //Image variables
  late String name;
  File? image;
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
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up", style: HEADLINE_BOLD_WHITE),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(clipBehavior: Clip.none, children: [
                Container(
                    height: 120.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: (image != null)
                              ? FileImage(image!) as ImageProvider
                              : const AssetImage(
                                  "assets/images/DefaultIcon.png"),
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle)),
                Positioned(
                    top: 85,
                    left: 32,
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
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: "Enter Username",
                    labelStyle: TextStyle(
                        fontFamily: "VisbyMedium", color: COLOR_INDIGO_LIGHT),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: COLOR_INDIGO_LIGHT, width: 3.0)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: COLOR_INDIGO_LIGHT,
                        width: 3.0,
                      ),
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Username";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: emailController,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: "Enter Email Address",
                    labelStyle: TextStyle(
                        fontFamily: "VisbyMedium", color: COLOR_INDIGO_LIGHT),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: COLOR_INDIGO_LIGHT, width: 3.0)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: COLOR_INDIGO_LIGHT,
                        width: 3.0,
                      ),
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? "Enter a valid email"
                          : null,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: passwordController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: "Enter Password",
                    labelStyle: TextStyle(
                        fontFamily: "VisbyMedium", color: COLOR_INDIGO_LIGHT),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: COLOR_INDIGO_LIGHT, width: 3.0)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: COLOR_INDIGO_LIGHT,
                        width: 3.0,
                      ),
                    ),
                  ),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != null && value.length < 6
                      ? "Password must be at least 6 characters!"
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                icon: const Icon(Icons.arrow_forward, size: 32),
                label: const Text(
                  "Sign Up",
                  style: TextStyle(fontFamily: "VisbyMedium", fontSize: 24),
                ),
                onPressed: signUp,
              ),
              const SizedBox(height: 20),
              RichText(
                  text: TextSpan(
                style: const TextStyle(
                    fontFamily: "VisbyMedium",
                    color: COLOR_INDIGO_LIGHT,
                    fontSize: 20),
                text: "Already have an account? ",
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onClickedSignIn,
                    text: "Log In",
                    style: const TextStyle(
                        fontFamily: "VisbyMedium",
                        decoration: TextDecoration.underline,
                        color: COLOR_INDIGO_LIGHT),
                  ),
                  const TextSpan(
                      text: " or ",
                      style: TextStyle(
                          fontFamily: "VisbyMedium",
                          color: COLOR_INDIGO_LIGHT)),
                  TextSpan(
                    recognizer: TapGestureRecognizer()..onTap = guestLogin,
                    text: "Login as Guest",
                    style: const TextStyle(
                        fontFamily: "VisbyMedium",
                        decoration: TextDecoration.underline,
                        color: COLOR_INDIGO_LIGHT),
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  Future signUp() async {
    String imageURL = await uploadPicture(image!);
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await firebaseAuth
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim())
          .then((result) {
        databaseReference.child(result.user!.uid).set({
          "email": emailController.text,
          "username": usernameController.text,
          'userPictureID': imageURL,
        });
      });
    } on FirebaseAuthException catch (e) {
      print(e);

      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  Future guestLogin() async {
    await firebaseAuth.signInAnonymously();
  }
}
