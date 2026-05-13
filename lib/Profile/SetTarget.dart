import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Profile/Profile.dart';
import 'package:medichat/components/Rounded_numeric_input.dart';
import 'package:medichat/components/connection.dart';
import 'package:medichat/components/rounded_button.dart';
import 'package:medichat/global_nav_bar.dart';

class SetTargetScreen extends StatefulWidget {
  @override
  State<SetTargetScreen> createState() => _SetTargetScreenState();
}

class _SetTargetScreenState extends State<SetTargetScreen> {
  TextEditingController water = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController calorie = TextEditingController();

  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _getTargetData();
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
            iconSize: 40
        ),
        title: Text(
          "Set Target",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())  // Show loader until data is fetched
          : SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RoundedNumInput(controller: weight, icon: Icons.monitor_weight_rounded, hint: "Weight:", suffix: "kg"),
                    RoundedNumInput(controller: water, icon: Icons.water_drop_outlined, hint: "Water Consumption:", suffix: "ml"),
                    RoundedNumInput(controller: calorie, icon: Icons.local_fire_department_outlined, hint: "Calorie Consumption:", suffix: "kcal"),
                    SizedBox(height: 30),
                    SizedBox(
                        width: double.infinity,
                        child: RoundedButton(title: "Save", onPressed: _editTarget)
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

  Future<void> _editTarget() async {
    try {
      final String? uid = ConnectionService.getUID();
      const MethodChannel _channel = MethodChannel('Target');

      final String result = await _channel.invokeMethod('editTargetData', {
        "userId": uid,
        "weight": double.parse(weight.text),
        "water": double.parse(water.text),
        "calorie": double.parse(calorie.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Target Saved Successfully"), duration: Duration(seconds: 1)),
      );

      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);  // To pop the current screen before pushing the new screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GlobalNavBar(initialIndex: 3,)),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${e.message}")));
    }
  }

  Future<void> _getTargetData() async {
    final String? uid = ConnectionService.getUID();
    final data = await TargetService.fetchTargetData(uid!);

    setState(() {
      if (data != null) {
        weight.text = data['weight'].toString();
        water.text = data['water'].toString();
        calorie.text = data['calorie'].toString();
      } else {
        weight.text = "0";
        water.text = "0";
        calorie.text = "0";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: Unable to fetch target data")));
      }
      isLoading = false; // Data is loaded, hide loader
    });
  }
}

class TargetService {
  static const MethodChannel _channel = MethodChannel('Target');

  static Future<Map<String, dynamic>?> fetchTargetData(String userId) async {
    try {
      final result = await _channel.invokeMethod('fetchTargetData', {'userId': userId});
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        print("Unexpected result type: ${result.runtimeType}");
        return null;
      }
    } on PlatformException catch (e) {
      print("Error fetching target data: ${e.message}");
      return null;
    }
  }
}
