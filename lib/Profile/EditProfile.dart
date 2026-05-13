import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Profile/Profile.dart';
import 'package:medichat/components/Rounded_numeric_input.dart';
import 'package:medichat/components/connection.dart';
import 'package:medichat/components/rounded_button.dart';
import 'package:medichat/components/rounded_input.dart';
import 'package:medichat/global_nav_bar.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController height = TextEditingController();
  TextEditingController age = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 246, 233),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 251, 246, 233),
        centerTitle: true,
        leading: IconButton(
          onPressed: () { Navigator.pop(context); },
          icon: Icon(Icons.chevron_left),
          iconSize: 40,
        ),
        title: Text("Edit Profile", style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
        )),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RoundedInput(controller: name, icon: Icons.drive_file_rename_outline_outlined, hint: "Enter Username"),
                    RoundedNumInput(controller: weight, icon: Icons.monitor_weight_rounded, hint: "Weight:", suffix: "kg"),
                    RoundedNumInput(controller: height, icon: Icons.height_rounded, hint: "Height:", suffix: "m"),
                    RoundedNumInput(controller: age, icon: Icons.person, hint: "Age:", suffix: "years' old"),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: RoundedButton(
                        title: "Save",
                        onPressed: () { _editProfile(); },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _editProfile() async {
    try {
      final String? uid = ConnectionService.getUID();
      const MethodChannel _channel = MethodChannel('Profile');

      final String result = await _channel.invokeMethod('editProfileData', {
        "userId": uid,
        "name": name.text,
        "weight": double.parse(weight.text),
        "height": double.parse(height.text),
        "age": int.parse(age.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile Saved Successfully"),
          duration: Duration(seconds: 1), // Set the duration to 1 second
        ),
      );

      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);  // To pop the current screen before pushing the new screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GlobalNavBar(initialIndex: 3,)),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${e.message}")));
    }
  }

  Future<void> _getProfileData() async {
    final String? uid = ConnectionService.getUID();
    final data = await ProfileService.fetchProfileData(uid!);

    if (data != null) {
      setState(() {
        name.text = data['name'].toString();
        weight.text = data['weight'].toString();
        height.text = data['height'].toString();
        age.text = data['age'].toString();
        isLoading = false;  // Data loaded, stop loading
      });
    } else {
      setState(() {
        isLoading = false;  // Even if data is null, stop loading
      });
    }
  }
}

class ProfileService {
  static const MethodChannel _channel = MethodChannel('Profile');

  // Fetch water consumption data from native Android code
  static Future<Map<String, dynamic>?> fetchProfileData(String userId) async {
    try {
      final result = await _channel.invokeMethod('fetchProfileData', {
        'userId': userId,
      });

      // Ensure the result is a Map and cast it properly
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        print("Unexpected result type: ${result.runtimeType}");
        return null;
      }
    } on PlatformException catch (e) {
      print("Error fetching water data: ${e.message}");
      return null;
    }
  }
}