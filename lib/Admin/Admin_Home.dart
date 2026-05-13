import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medichat/Admin/ADmin_Feedback.dart';
import 'package:medichat/Admin/Admin_Blog.dart';
import 'package:medichat/Login/Login.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin Home'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(context, 'Add Blog', Icons.article, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminBlog()),
              );
            }),
            const SizedBox(height: 10),
            _buildButton(context, 'Read Feedback', Icons.feedback, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminFeedback()),
              );
            }),
            const SizedBox(height: 10),
            _buildButton(context, 'Log Out', Icons.logout, () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontSize: 16)),
        onPressed: onPressed,
      ),
    );
  }
}
