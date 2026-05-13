import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medichat/Login/constants.dart';
import 'global_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBtGfgqDPGm-CZjkN0r6AWmlJO7ipsQHzE",
      appId: "1:326674692268:android:f67a4b56daea60be4d8709",
      messagingSenderId: "326674692268",
      projectId: "medichat-2029e",
      storageBucket: "medichat-2029e.firebasestorage.app",
      databaseURL: "https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app",
    ),
  );
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: kPrimaryColor,
      ),
      home: GlobalNavBar(),
    );
  }
}
