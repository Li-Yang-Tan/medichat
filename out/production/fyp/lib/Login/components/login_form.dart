import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:medichat/Login/Setup.dart';
import 'package:medichat/components/rounded_button.dart';
import 'package:medichat/components/rounded_input.dart';
import 'package:medichat/components/rounded_password_input.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    Key? key,
    required this.isLogin,
    required this.animationDuration,
    required this.size,
    required this.defaultLoginSize,
    required this.onLoginSuccess, // Callback for login success
    required this.onLoginFailure,
  }) : super(key: key);

  final bool isLogin;
  final Duration animationDuration;
  final Size size;
  final double defaultLoginSize;
  final Function(User) onLoginSuccess; // Callback for login success
  final Function(String) onLoginFailure;

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return AnimatedOpacity(
      opacity: isLogin ? 1.0 : 0.0,
      duration: animationDuration * 4,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: size.width,
          height: defaultLoginSize,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24
                  ),
                ),

                SizedBox(height: 20),

                Image.asset(
                  "assets/MediChat.png",
                  height: 100,
                  width: 100,
                ),

                SizedBox(height: 40),

                RoundedInput(icon: Icons.mail, hint: 'Email Address', controller: emailController,),

                RoundedPasswordInput(hint: 'Password', controller: passwordController,),

                SizedBox(height: 10),

                RoundedButton(
                  title: 'LOGIN',
                  onPressed: () {
                    if (passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please Enter Password!")),
                      );
                      return;
                    }

                    if (emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please Enter Email!")),
                      );
                      return;
                    }

                    _login(emailController.text, passwordController.text, context);
                  },
                ),

                SizedBox(height: 10),

              ],
            ),
          ),
        ),
      ),
    );
  }

  //login logic
  void _login(String email, String password, BuildContext context) async {
    try {
      // Validate email format
      if (!_validateEmail(email)) {
        onLoginFailure("Invalid email format");
        return;
      }

      // Attempt Firebase login
      final FirebaseAuth auth = FirebaseAuth.instance;

      // Sign in using Firebase Auth
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Ensure UID is not null
        String? userId = user.uid;
        if (userId == null) {
          onLoginFailure("User UID is null.");
          return;
        }

        // After login, check if user has set up their profile
        DatabaseReference databaseReference = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app',
        ).ref()
            .child("User")
            .child(userId);

        databaseReference.child("Age").get().then((snapshot) {
          if (snapshot.exists) {
            // If username exists, call success callback
            onLoginSuccess(user);
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SetupPage()),
              );
            });
          }
        }).catchError((error) {
          // Log the error and handle it
          onLoginFailure("Error checking user profile: ${error.toString()}");
        });
      } else {
        onLoginFailure("User is null after login attempt.");
      }
    } catch (e) {
      onLoginFailure("Invalid email address or password. Please try again.");
    }
  }

// Validate email format
  bool _validateEmail(String email) {
    final regex = RegExp(
        r"^[a-zA-Z0-9_+&*-]+(?:\.[a-zA-Z0-9_+&*-]+)*@(gmail\.com|hotmail\.com)$");
    return regex.hasMatch(email);
  }

}