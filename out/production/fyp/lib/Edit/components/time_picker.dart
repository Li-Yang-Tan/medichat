import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class TimePickerDialog2 extends StatefulWidget {
  const TimePickerDialog2({super.key});

  @override
  State<TimePickerDialog2> createState() => _TimePickerDialog2State();
}

class _TimePickerDialog2State extends State<TimePickerDialog2> {
  var hour = 0;
  var minute = 0;
  var hourFormat = "H";
  var minuteFormat = "M";

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
                Text(
                  "H",
                  style: TextStyle(color: Colors.grey, fontSize: 20),
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
                Text(
                  "M",
                  style: TextStyle(color: Colors.grey, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, "$hour" + "h" + (minute == 0 ? "" : " ${minute.toString().padLeft(2, '0')}m"));},
              child: const Text("Confirm", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> showTimePickerDialog2(BuildContext context) async {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return const TimePickerDialog2();
    },
  );
}
