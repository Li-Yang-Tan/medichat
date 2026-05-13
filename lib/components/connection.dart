import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medichat/Login/Login.dart';

class ConnectionService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if a user is logged in, otherwise redirect to login page
  static void checkSession(BuildContext context) {
    User? user = _auth.currentUser;
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  /// Get the current user's UID
  static String? getUID() {
    User? user = _auth.currentUser;
    return user?.uid;
  }
}
