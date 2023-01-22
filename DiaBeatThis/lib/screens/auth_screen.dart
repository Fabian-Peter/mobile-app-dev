import 'package:diabeatthis/screens/login_screen.dart';
import 'package:diabeatthis/screens/signUp_screen.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreen();
}

class _AuthScreen extends State<AuthScreen> {
  bool isLogin = true;
  
  @override
  Widget build(BuildContext context) {
    return isLogin ? LoginScreen(onClickedSignUp: toggle) : SignUpScreen(onClickedSignIn: toggle);
  }

  void toggle() {
    setState(() => isLogin = !isLogin);
  }
}