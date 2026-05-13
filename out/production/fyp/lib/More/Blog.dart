import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogScreen extends StatefulWidget {
  @override
  _BlogScreenState createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  List<Map<String, dynamic>> blogList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getBlogData();
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
        title: Text("Blog", style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
        )),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : blogList.isEmpty
          ? Center(child: Text("No blog posts found."))
          : ListView.builder(
        itemCount: blogList.length,
        itemBuilder: (context, index) {
          return BlogCard(blog: blogList[index]);
        },
      ),
    );
  }

  Future<void> _getBlogData() async {
    final result = await BlogService.fetchBlogData();

    if (result != null) {
      setState(() {
        blogList = result;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Unable to fetch blog data")),
      );
    }
  }
}

class BlogCard extends StatelessWidget {
  final Map<String, dynamic> blog;

  BlogCard({required this.blog});

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Optionally handle the error by showing a message to the user
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract values from the blog Map
    final String date = blog['date'] ?? '';
    final String title = blog['title'] ?? '';
    final String description = blog['description'] ?? '';
    final String link = blog['link'] ?? '';

    return GestureDetector(
      onTap: () => _launchURL(link),
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 23,
                ),
              ),
              SizedBox(height: 5),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class BlogService {
  static const MethodChannel _channel = MethodChannel('Blog');

  static Future<List<Map<String, dynamic>>?> fetchBlogData() async {
    try {
      final result = await _channel.invokeMethod('FetchBlogData', {});
      if (result is List) {
        return result.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return null;
    } on PlatformException catch (e) {
      print("Error fetching blog data: ${e.message}");
      return null;
    }
  }
}
