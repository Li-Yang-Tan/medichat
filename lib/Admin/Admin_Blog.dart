import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Admin/Admin_Home.dart';
import 'package:intl/intl.dart';

class AdminBlog extends StatefulWidget {
  const AdminBlog({Key? key}) : super(key: key);

  @override
  _AdminBlogState createState() => _AdminBlogState();
}

class _AdminBlogState extends State<AdminBlog> {
  final TextEditingController date = TextEditingController();
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController link = TextEditingController();

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left),
          iconSize: 40,
        ),
        title: Text(
          "Add Blog Post",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildInputField(controller: date, hint: "Date (yyyy-MM-dd):", icon: Icons.date_range, onTap: () => _selectDate(context)),
              _buildInputField(controller: title, hint: "Enter Title:", icon: Icons.title),
              _buildInputField(controller: description, hint: "Enter Description:", icon: Icons.description),
              _buildInputField(controller: link, hint: "Enter Link:", icon: Icons.link),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                ),
                onPressed: _validateAndAddBlog,
                child: Text("Add Blog", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String hint, required IconData icon, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: onTap != null,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _validateAndAddBlog() {
    if (date.text.isEmpty || title.text.isEmpty || description.text.isEmpty || link.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields must be filled!")),
      );
      return;
    }
    _AddBlog();
  }

  Future<void> _AddBlog() async {
    MethodChannel platform = MethodChannel('AdBlog');
    try {
      final String result = await platform.invokeMethod('UploadBlog', {
        "date": date.text,
        "title": title.text,
        "description": description.text,
        "link": link.text
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Blog Added Successfully"),
          duration: Duration(seconds: 1),
        ),
      );

      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminHome()),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${e.message}")));
    }
  }
}
