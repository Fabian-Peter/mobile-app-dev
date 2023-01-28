import 'package:diabeatthis/screens/home_screen.dart';
import 'package:diabeatthis/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child("Users");

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: const Text("Settings", style: HEADLINE_BOLD_WHITE)),
        body: Form(
          key: _formKey,
          child: ListView(children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),
                ],
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Enter Username",
                  labelStyle: TextStyle(
                      fontFamily: "VisbyMedium",
                      fontSize: 14,
                      color: COLOR_INDIGO_LIGHT),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: COLOR_INDIGO_LIGHT)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: COLOR_INDIGO_LIGHT,
                      width: 3.0,
                    ),
                  ),
                ),
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
                decoration: const InputDecoration(
                  labelText: "Enter Email",
                  labelStyle: TextStyle(
                      fontFamily: "VisbyMedium",
                      fontSize: 14,
                      color: COLOR_INDIGO_LIGHT),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: COLOR_INDIGO_LIGHT)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: COLOR_INDIGO_LIGHT,
                      width: 3.0,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter an Email Address";
                  } else if (!value.contains("@")) {
                    return "Please enter a valid email address";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: "Enter Password",
                  labelStyle: TextStyle(
                      fontFamily: "VisbyMedium",
                      fontSize: 14,
                      color: COLOR_INDIGO_LIGHT),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: COLOR_INDIGO_LIGHT)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: COLOR_INDIGO_LIGHT,
                      width: 3.0,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Password";
                  } else if (value.length < 6) {
                    return "Password must be at least 6 characters!";
                  }
                  return null;
                },
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40)),
                        icon: const Icon(Icons.save_as, size: 20),
                        label: const Text(
                          "Submit",
                          style: TextStyle(
                              fontFamily: "VisbyMedium", fontSize: 20),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            registerToFb();
                          }
                        }))
          ]),
        ));
  }

  void registerToFb() {
    firebaseAuth
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((result) {
      databaseReference.child(result.user!.uid).set({
        "email": emailController.text,
        "username": usernameController.text,
      }).then((res) {
        isLoading = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(uid: result.user!.uid)),
        );
      });
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(err.message),
              actions: [
                TextButton(
                  child: const Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
