import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Add/components/number_page.dart';
import 'package:medichat/Diary/Diary.dart';
import 'package:medichat/components/Rounded_numeric_input.dart';
import 'package:medichat/components/connection.dart';
import 'package:medichat/components/rounded_button.dart';
import 'package:medichat/components/rounded_input.dart';
import 'package:medichat/global_nav_bar.dart';
import 'package:intl/intl.dart';

class AddWaterScreen extends StatefulWidget {
  @override
  State<AddWaterScreen> createState() => _SetAddWaterScreenState();
}

class _SetAddWaterScreenState extends State<AddWaterScreen> {
  final String? uid = ConnectionService.getUID();

  TextEditingController date = TextEditingController();
  TextEditingController time = TextEditingController();
  TextEditingController water = TextEditingController();

  MethodChannel platform = MethodChannel('AddWater');

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        date.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Add Water Record",
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
                    GestureDetector(
                      onTap: () async {
                        // Show the time picker dialog
                        String? selectedTime = await showTimePickerDialog(context);
                        if (selectedTime != null) {
                          // Update the controller's text with the selected time
                          setState(() {
                            time.text = selectedTime;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: RoundedInput(
                          controller: time,  // Use 'time' here as the controller for the time input field
                          icon: Icons.access_time_rounded,
                          hint: "Time:",
                        ),
                      ),
                    ),
                    RoundedNumInput(
                      controller: water,
                      icon: Icons.water_drop_outlined,
                      hint: "Water:",
                      suffix: "ml",
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: RoundedButton(
                          title: "Add",
                          onPressed: () {
                            if (date.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Date cannot be empty!")),
                              );
                              return;
                            }

                            if (time.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Time cannot be empty!")),
                              );
                              return;
                            }

                            if (water.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Water amount cannot be empty!")),
                              );
                              return;
                            }

                            double? parsedWater = double.tryParse(water.text);
                            if (parsedWater == null || parsedWater <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please enter a valid water amount.")),
                              );
                              return;
                            }

                            _AddWater(); // Proceed if all inputs are valid
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

  Future<void> _AddWater() async {
    try {
      final String result = await platform.invokeMethod('AddWater', {
        "userId": uid,
        "date": date.text,
        "time": time.text,
        "water": double.parse(water.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Record Added Successfully"),
          duration: Duration(seconds: 1), // Set the duration to 1 second
        ),
      );

      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);  // To pop the current screen before pushing the new screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GlobalNavBar()),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${e.message}")));
    }
  }
}
