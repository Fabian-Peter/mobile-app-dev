import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../classes/utils.dart';
import '../main.dart';
import '../utils/constants.dart';

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
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child("Users");

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
              const SizedBox(height: 40),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                    labelText: "Enter Username", isDense: true),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Username";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration:
                    const InputDecoration(labelText: "Enter Email Address"),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? "Enter a valid email"
                        : null,
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: passwordController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: "Enter Password"),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6
                    ? "Password must be at least 6 characters!"
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                icon: const Icon(Icons.arrow_forward, size: 32),
                label: const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: singUp,
              ),
              const SizedBox(height: 20),
              RichText(
                  text: TextSpan(
                style: const TextStyle(color: COLOR_INDIGO_LIGHT, fontSize: 20),
                text: "Already have an account? ",
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onClickedSignIn,
                    text: "Log In",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  const TextSpan(text: " or "),
                  TextSpan(
                    recognizer: TapGestureRecognizer()..onTap = guestLogin,
                    text: "Login as Guest",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.secondary),
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  Future singUp() async {
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
          "username": usernameController.text
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
