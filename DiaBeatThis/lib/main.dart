import 'package:diabeatthis/screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:diabeatthis/screens/home_screen.dart';
import 'package:diabeatthis/screens/game_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:diabeatthis/utils/constants.dart';

import 'classes/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final user = await FirebaseAuth.instance.authStateChanges().first;
  if (user == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }
  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: Utils.messengerKey,
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: COLOR_INDIGO,
      ),
      home: FutureBuilder(
          future: _fbApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('error${snapshot.error.toString()}');
              return const Text('Something went wrong!');
            } else if (snapshot.hasData) {
              return const AuthGate();
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
      // other providers
    ]);
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong!"));
          } else if (!snapshot.hasData) {
            return AuthScreen();
          }
          return HomeScreen();
        });
  }
}
