import 'package:flutter/material.dart';
import 'package:medichat/Admin/Admin_Home.dart';
import 'package:medichat/More/Blog.dart';
import 'package:medichat/More/FAQ.dart';
import 'package:medichat/More/Feedback.dart';
import 'package:medichat/More/Setting.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 251, 246, 233),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 251, 246, 233),
          centerTitle: true,
          title: Text("More", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                profileMenu(title: "Settings", icon: Icons.settings, onPress:(){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                }),
                profileMenu(title: "Feedback", icon: Icons.feedback_outlined, onPress:(){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackScreen()));
                }),
                profileMenu(title: "Blog", icon: Icons.pageview_outlined, onPress:()async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BlogScreen()));
                }),
                profileMenu(title: "FAQ", icon: Icons.question_answer_outlined, onPress:()async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FAQScreen()));
                }),
                profileMenu(title: "Admin Page", icon: Icons.admin_panel_settings_outlined, onPress:()async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminHome()));
                }),
              ],
            ),
          ),
        )
    );
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
  }): super(key: key);

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
        width: 35, height: 35,
        decoration: BoxDecoration(
          borderRadius:  BorderRadius.circular(100),
          color: Colors.green.shade100,
        ),
        child: Icon(icon, color: Color.fromARGB(255, 98, 130, 93)),
      ),
      title: Text(title),
      trailing: endIcon? Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.green.shade50,
          ),
          child: const Icon(Icons.keyboard_arrow_right)): null,
    );
  }
}