import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:medichat/components/rounded_button.dart';
import 'package:medichat/components/rounded_input.dart';
import 'package:medichat/components/rounded_password_input.dart';
import 'dart:developer';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    Key? key,
    required this.isLogin,
    required this.animationDuration,
    required this.size,
    required this.defaultLoginSize,
  }) : super(key: key);

  final bool isLogin;
  final Duration animationDuration;
  final Size size;
  final double defaultLoginSize;

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return AnimatedOpacity(
      opacity: isLogin ? 0.0 : 1.0,
      duration: animationDuration * 5,
      child: Visibility(
        visible: !isLogin,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: size.width,
            height: defaultLoginSize,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  SizedBox(height: 10),

                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24
                    ),
                  ),

                  SizedBox(height: 40),

                  RoundedInput(icon: Icons.mail, hint: 'Email Address', controller: emailController,),

                  RoundedInput(icon: Icons.face_rounded, hint: 'Username', controller: usernameController,),

                  RoundedPasswordInput(hint: 'Password', controller: passwordController,),

                  SizedBox(height: 10),

                  RoundedButton(
                    title: 'SIGN UP',
                    onPressed: () {
                      _register(context, emailController.text, usernameController.text, passwordController.text);
                    },
                  ),

                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Firebase Registration Logic
  void _register(BuildContext context, String email, String username, String password) async {
    if (!_validateEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid email format. Please enter a valid email.")));
      return;
    }

    try {
      // Validate email, password, and username
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All fields are required")));
        return;
      }

      // Register user with Firebase Authentication
      final FirebaseAuth auth = FirebaseAuth.instance;

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        // Create a record in Firebase Realtime Database
        DatabaseReference userRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app',
        ).ref()
            .child('User')
            .child(user.uid);

        await userRef.set({
          'Username': username,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration Successful! Please verify your email.")));
      }
    } catch (e) {
      // Handle registration errors
      String errorMessage = _handleRegistrationError(e as Exception);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  // Handle different Firebase authentication errors
  String _handleRegistrationError(Exception e) {
    print("Registration error: $e"); // 👈 log here

    if (e is FirebaseAuthException) {
      if (e.code == 'email-already-in-use') {
        return 'Email is already in use.';
      } else if (e.code == 'weak-password') {
        return 'The password is too weak.';
      } else {
        return 'Registration failed: ${e.message}';
      }
    }
    return 'Unknown error occurred.';
  }

  // Validate email format
  bool _validateEmail(String email) {
    final regex = RegExp(
        r"^[a-zA-Z0-9_+&*-]+(?:\.[a-zA-Z0-9_+&*-]+)*@(gmail\.com|hotmail\.com)$");
    return regex.hasMatch(email);
  }
}