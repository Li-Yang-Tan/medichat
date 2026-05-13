import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminFeedback extends StatefulWidget {
  const AdminFeedback({Key? key}) : super(key: key);

  @override
  State<AdminFeedback> createState() => _AdminFeedbackState();
}

class _AdminFeedbackState extends State<AdminFeedback> {
  List<Map<String, dynamic>> feedbackList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getFeedbackData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Feedback'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader while fetching data
          : feedbackList.isEmpty
          ? const Center(child: Text("No feedback available"))
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: feedbackList.length,
          itemBuilder: (context, index) {
            final feedback = feedbackList[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.feedback, color: Colors.blue),
                title: Text(feedback['title'] ?? 'No Title', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text(feedback['body'] ?? 'No Content'),
                trailing: Text(feedback['date'] ?? 'Unknown Date', style: const TextStyle(fontSize: 12)),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _getFeedbackData() async {
    final result = await FeedbackService.fetchFeedbackData();

    if (result != null) {
      setState(() {
        feedbackList = result;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Unable to fetch feedback data")),
      );
    }
  }
}

class FeedbackService {
  static const MethodChannel _channel = MethodChannel('AdFeedback');

  static Future<List<Map<String, dynamic>>?> fetchFeedbackData() async {
    try {
      final result = await _channel.invokeMethod('fetchFeedback', {});
      if (result is List) {
        return result.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return null;
    } on PlatformException catch (e) {
      print("Error fetching feedback data: ${e.message}");
      return null;
    }
  }
}
