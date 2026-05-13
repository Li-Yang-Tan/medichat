import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class TimePickerDialog extends StatefulWidget {
  const TimePickerDialog({super.key});

  @override
  State<TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<TimePickerDialog> {
  var hour = 0;
  var minute = 0;
  var timeFormat = "AM";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10)),
        constraints: BoxConstraints(
          maxHeight: 300,  // You can adjust this value to make it shorter or taller
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NumberPicker(
                  minValue: 0,
                  maxValue: 12,
                  value: hour,
                  zeroPad: true,
                  infiniteLoop: true,
                  itemWidth: 80,
                  itemHeight: 60,
                  onChanged: (value) {
                    setState(() {
                      hour = value;
                    });
                  },
                  textStyle: const TextStyle(color: Colors.grey, fontSize: 20),
                  selectedTextStyle: const TextStyle(color: Colors.black87, fontSize: 30),
                  decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Colors.black87),
                        bottom: BorderSide(color: Colors.black87)),
                  ),
                ),
                NumberPicker(
                  minValue: 0,
                  maxValue: 59,
                  value: minute,
                  zeroPad: true,
                  infiniteLoop: true,
                  itemWidth: 80,
                  itemHeight: 60,
                  onChanged: (value) {
                    setState(() {
                      minute = value;
                    });
                  },
                  textStyle: const TextStyle(color: Colors.grey, fontSize: 20),
                  selectedTextStyle: const TextStyle(color: Colors.black87, fontSize: 30),
                  decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Colors.black87),
                        bottom: BorderSide(color: Colors.black87)),
                  ),
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          timeFormat = "AM";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: timeFormat == "AM"
                              ? Colors.grey.shade800
                              : Colors.grey.shade700,
                          border: Border.all(
                            color: timeFormat == "AM"
                                ? Colors.grey
                                : Colors.grey.shade700,
                          ),
                        ),
                        child: const Text(
                          "AM",
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          timeFormat = "PM";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: timeFormat == "PM"
                              ? Colors.grey.shade800
                              : Colors.grey.shade700,
                          border: Border.all(
                            color: timeFormat == "PM"
                                ? Colors.grey
                                : Colors.grey.shade700,
                          ),
                        ),
                        child: const Text(
                          "PM",
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, "$hour:${minute.toString().padLeft(2, '0')} $timeFormat");
              },
              child: const Text("Confirm", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> showTimePickerDialog(BuildContext context) async {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return const TimePickerDialog();
    },
  );
}
