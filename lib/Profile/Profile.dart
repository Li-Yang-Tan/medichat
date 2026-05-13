import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Login/Login.dart';
import 'package:medichat/Profile/EditProfile.dart';
import 'package:medichat/Profile/SetTarget.dart';
import 'package:medichat/components/connection.dart';
import 'package:medichat/components/rounded_button.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 246, 233),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 251, 246, 233),
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              // Profile Image/Icon
              SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: const Icon(
                    Icons.account_circle,
                    size: 120, // Match the size of the Image
                    color: Color.fromARGB(255, 98, 130, 93),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // User Name & Email
              Text(name, style: TextStyle(fontSize: 23)),
              Text(email, style: TextStyle(fontSize: 15)),

              const SizedBox(height: 20),

              SizedBox(
                width: 200,
                child: RoundedButton(
                  title: "Set Target",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SetTargetScreen()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              // Profile Menu Options
              profileMenu(
                title: "Edit Profile",
                icon: Icons.account_circle,
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfileScreen()),
                  );
                },
              ),
              profileMenu(title: "Settings", icon: Icons.settings, onPress: () {}),
              profileMenu(
                title: "Log Out",
                icon: Icons.logout_rounded,
                onPress: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getData() async {
    final String? uid = ConnectionService.getUID();
    final data = await ProfileService.fetchUserData(uid!);

    if (data != null) {
      setState(() {
        name = data['name'] ?? "";
        email = data['email'] ?? "";
      });
    }
  }
}

class profileMenu extends StatelessWidget {
  const profileMenu({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.green.shade100,
        ),
        child: Icon(icon, color: Color.fromARGB(255, 98, 130, 93)),
      ),
      title: Text(title),
      trailing: endIcon
          ? Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.green.shade50,
        ),
        child: const Icon(Icons.keyboard_arrow_right),
      )
          : null,
    );
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
