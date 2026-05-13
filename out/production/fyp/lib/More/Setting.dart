import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Chat/ChatDatabase.dart';
import 'package:medichat/Login/Login.dart';
import 'package:medichat/Profile/EditProfile.dart';
import 'package:medichat/components/connection.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String username = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 133, 169, 143),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 133, 169, 143),
        centerTitle: true,
        leading: IconButton(
          onPressed: () { Navigator.pop(context); },
          icon: Icon(Icons.chevron_left, color: Colors.white,),
          iconSize: 40,
        ),
        title: Text("Settings", style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.white
        )),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          Expanded(child: _buildSettings()),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 133, 169, 143),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30, // Circle size
            child: Icon(
              Icons.account_circle,
              size: 50,
              color: Color.fromARGB(255, 98, 130, 93), // Icon color
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                email,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          Spacer(),
          IconButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfileScreen()),
            );
          }, icon: Icon(Icons.edit, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      width: double.infinity, // Ensures full width
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 251, 246, 233),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns everything to the left
          children: [
            Text(
              'Account Settings',
              style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _buildMenuItem(Icons.password_outlined, 'Change Password', 'Change your account passwords', () {
              showChangePasswordDialog(context);
            }),

            _buildMenuItem(Icons.delete_forever_outlined, 'Delete Account', 'Delete and remove your account and data', () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Confirm Deletion"),
                  content: Text("Are you sure you want to delete your account? This action cannot be undone."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Cancel
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the confirmation dialog
                        reauthenticateAndDeleteUser(context); // Call the deletion function
                      },
                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 10),

            Text(
              'Chatbot Settings',
              style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _buildMenuItem(Icons.clear_rounded, 'Clear Chat History', 'Clear all chat history with our chatbot', () {
              _clearChatHistory(context);
            }),
            SizedBox(height: 10),

            Text(
              'Others',
              style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _buildMenuItem(Icons.logout_rounded, 'Log Out', 'Log out from your account', () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }),
          ],
        )

      )
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Color.fromARGB(255, 98, 130, 93)),
      title: Text(title, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.black87, fontSize: 14)),
      onTap: onTap, // Use the passed function
    );
  }

  Future<void> _getData() async {
    final String? uid = ConnectionService.getUID();
    final data = await ProfileService.fetchUserData(uid!);

    if (data != null) {
      setState(() {
        username = data['name'] ?? "";
        email = data['email'] ?? "";
      });
    }
  }

  Future<void> reauthenticateAndDeleteUser(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No user is signed in")),
      );
      return;
    }

    String? password = await showDialog(
      context: context,
      builder: (context) {
        TextEditingController passwordController = TextEditingController();
        return AlertDialog(
          title: Text("Confirm Password"),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: "Enter your password"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), // Cancel
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, passwordController.text), // Submit password
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (password == null || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password is required")),
      );
      return;
    }

    try {
      // Reauthenticate with the provided password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete account after successful reauthentication
      await user.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account successfully deleted")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void showChangePasswordDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController _currentPasswordController = TextEditingController();
    TextEditingController _newPasswordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();
    bool _isLoading = false;

    void changePassword() async {
      if (!_formKey.currentState!.validate()) return;

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No user signed in")));
        return;
      }

      try {
        // Reauthenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);

        // Check if new password matches confirmation
        if (_newPasswordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match")));
          return;
        }

        // Update the password
        await user.updatePassword(_newPasswordController.text);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password successfully changed")));

        Navigator.pop(context); // Close the dialog after success
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Change Password"),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _currentPasswordController,
                      decoration: InputDecoration(labelText: "Current Password"),
                      obscureText: true,
                      validator: (value) => value!.isEmpty ? "Enter current password" : null,
                    ),
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(labelText: "New Password"),
                      obscureText: true,
                      validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(labelText: "Confirm Password"),
                      obscureText: true,
                      validator: (value) => value != _newPasswordController.text ? "Passwords do not match" : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _isLoading = true);
                    changePassword();
                  },
                  child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Change"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _clearChatHistory(BuildContext context) async {
    bool confirm = await _showConfirmationDialog(context);
    if (confirm) {
      await ChatDatabase.instance.clearMessages();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Chat history cleared!")),
      );
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to clear all chat history?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Clear", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false; // Return false if the dialog is dismissed
  }
}

class ProfileService {
  static const MethodChannel _channel = MethodChannel('Profile');

  // Fetch user data from native Android code
  static Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      final result = await _channel.invokeMethod('fetchUserData');

      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        print("Unexpected result type: ${result.runtimeType}");
        return null;
      }
    } on PlatformException catch (e) {
      print("Error fetching user data: ${e.message}");
      return null;
    }
  }
}
