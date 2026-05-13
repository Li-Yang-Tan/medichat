import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/components/connection.dart';
import 'package:medichat/components/rounded_button.dart';
import 'package:medichat/global_nav_bar.dart';
import 'package:intl/intl.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final String? uid = ConnectionService.getUID();

  DateTime today = DateTime.now();
  DateFormat sdf = DateFormat('yyyy-MM-dd');
  
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();

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
          "Provide Feedback",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              TextField(
                controller: title,
                textInputAction: TextInputAction.done,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: "Enter Title",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: body,
                decoration: InputDecoration(
                  labelText: "Enter Body",
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
              ),
              SizedBox(height: 30),
              Center(
                child: RoundedButton(title: "Submit", onPressed: (){
                  if (title.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a title.")),
                    );
                    return;
                  }

                  if (body.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter the body.")),
                    );
                    return;
                  }
                  
                  _AddFeedback();
                }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _AddFeedback() async {
    MethodChannel platform = MethodChannel('Feedback');
    try {
      final String result = await platform.invokeMethod('addFeedbackData', {
        "userId": uid,
        "date": sdf.format(today),
        "title": title.text,
        "body": body.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Feedback Added Successfully"),
          duration: Duration(seconds: 1), // Set the duration to 1 second
        ),
      );

      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);  // To pop the current screen before pushing the new screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GlobalNavBar(initialIndex: 2,)),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${e.message}")));
    }
  }
}