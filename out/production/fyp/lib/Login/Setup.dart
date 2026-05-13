import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Login/constants.dart';
import 'package:medichat/components/input_container.dart';
import 'package:medichat/components/rounded_button.dart';
import 'package:medichat/global_nav_bar.dart';
import 'package:numberpicker/numberpicker.dart';

class SetupPage extends StatefulWidget {
  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  // Controller to get the values from text fields
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String selectedGender = "";
  int _currentValue = 0;

  static const platform = MethodChannel('Setup');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Center(
              child: Text(
                'Setting Up Your Account',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24
                ),
              ),
            ),
            SizedBox(height: 20),

            //Age Input
            InputContainer(
                child: TextField(
                  readOnly: true,
                  onTap: _showDialog,
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                      labelText: "Enter Age",
                      border: InputBorder.none
                  ),
                )),
            SizedBox(height: 20),

            // Gender Selection
            Text("Choose Gender: ", style: TextStyle(fontSize: 20)),
            Column(
              children: [
                RadioListTile<String>(
                  title: Text('Male'),
                  value: 'Male',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                  contentPadding: EdgeInsets.all(0), // Reducing padding
                ),
                RadioListTile<String>(
                  title: Text('Female'),
                  value: 'Female',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                  contentPadding: EdgeInsets.all(0), // Reducing padding
                ),
              ],
            ),
            SizedBox(height: 20),

            // Height Input
            InputContainer(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                      labelText: "Enter Height (m)",
                      border: InputBorder.none
                  ),
                )),
            SizedBox(height: 20),

            // Weight Input
            InputContainer(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                      labelText: "Enter Weight (kg)",
                      border: InputBorder.none
                  ),
                )),
            SizedBox(height: 20),

            // Submit Button
            RoundedButton(
              title: 'SET UP',
              onPressed: () {
                _sendDataToNative();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to send data to Java
  Future<void> _sendDataToNative() async {
    try {
      final String result = await platform.invokeMethod('addUser', {
        "age": int.parse(_ageController.text),
        "gender": selectedGender,
        "height": double.parse(_heightController.text),
        "weight": double.parse(_weightController.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Target Saved Successfully"), duration: Duration(seconds: 1)),
      );

      Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);  // To pop the current screen before pushing the new screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GlobalNavBar(initialIndex: 0,)),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${e.message}")));
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Your Age:'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NumberPicker(
                    minValue: 0,
                    maxValue: 100,
                    value: _currentValue,
                    onChanged: (newValue) {
                      setState(() {
                        _currentValue = newValue;
                        _ageController.text = _currentValue.toString();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
