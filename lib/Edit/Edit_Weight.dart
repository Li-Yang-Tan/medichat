import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Diary/Diary.dart';
import 'package:medichat/components/Rounded_numeric_input.dart';
import 'package:medichat/components/connection.dart';
import 'package:medichat/components/rounded_button.dart';
import 'package:medichat/components/rounded_input.dart';
import 'package:intl/intl.dart';

class EditWeightScreen extends StatefulWidget {
  @override
  State<EditWeightScreen> createState() => _SetEditWeightScreenState();
}

class _SetEditWeightScreenState extends State<EditWeightScreen> {
  final String? uid = ConnectionService.getUID();

  TextEditingController date = TextEditingController();
  TextEditingController weight = TextEditingController();

  MethodChannel platform = MethodChannel('AddWeight');

  String oldRecord = "";

  Future<void> _selectDate(BuildContext context) async {

  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    setState(() {
      String dateD = arguments['date'] ?? "";
      double weightD = arguments['weight'] ?? 0.0;
      oldRecord = dateD;

      // Update only the text fields dynamically, without reinitializing the controller
      date.text = dateD;
      weight.text = weightD.toString();
    });

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 246, 233),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 251, 246, 233),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left),
          iconSize: 40,
        ),
        title: Text(
          "Edit Weight",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: RoundedInput(
                          controller: date,
                          icon: Icons.date_range,
                          hint: "Date (yyyy-MM-dd):",
                        ),
                      ),
                    ),
                    RoundedNumInput(
                      controller: weight,
                      icon: Icons.monitor_weight_rounded,
                      hint: "Weight:",
                      suffix: "kg",
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: RoundedButton(
                        title: "Update",
                          onPressed: () {
                            if (date.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Date cannot be empty!")),
                              );
                              return;
                            }

                            if (weight.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Weight cannot be empty!")),
                              );
                              return;
                            }

                            double? parsedWeight = double.tryParse(weight.text);
                            if (parsedWeight == null || parsedWeight <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please enter a valid weight.")),
                              );
                              return;
                            }

                            _AddWeight(); // Proceed if all inputs are valid
                          }
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

  Future<void> _AddWeight() async {
    try {
      final String result = await platform.invokeMethod('UpdateWeight', {
        "userId": uid,
        "date": date.text,
        "weight": double.parse(weight.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Record Updated Successfully"),
          duration: Duration(seconds: 1), // Set the duration to 1 second
        ),
      );

      await Future.delayed(Duration(seconds: 1));
      Navigator.push(context, MaterialPageRoute(builder: (context) => DiaryScreen()));
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${e.message}")));
    }
  }
}
