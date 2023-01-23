import 'package:diabeatthis/classes/utils.dart';
import 'package:diabeatthis/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginScreen({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login", style: HEADLINE_BOLD_WHITE),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "Email Address",
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
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: passwordController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: "Password",
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
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              icon: const Icon(Icons.lock_open, size: 32),
              label: const Text(
                "Sign In",
                style: TextStyle(fontFamily: "VisbyMedium", fontSize: 24),
              ),
              onPressed: singIn,
            ),
            const SizedBox(height: 24),
            RichText(
                text: TextSpan(
              style: const TextStyle(
                  fontFamily: "VisbyMedium",
                  color: COLOR_INDIGO_LIGHT,
                  fontSize: 20),
              text: "No account?  ",
              children: [
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = widget.onClickedSignUp,
                  text: "Sign Up",
                  style: const TextStyle(
                      fontFamily: "VisbyMedium",
                      decoration: TextDecoration.underline,
                      color: COLOR_INDIGO_LIGHT),
                ),
                const TextSpan(text: " or "),
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
    );
  }

  Future singIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      print(e);

      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  Future guestLogin() async {
    await FirebaseAuth.instance.signInAnonymously();
  }
}
