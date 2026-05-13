import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  final Map<String, List<Map<String, String>>> faqData = {
    "General Questions": [
      {"question": "What is this app, and how does it work?", "answer": "This is a health and fitness tracking app that allows users to record their daily health data."},
      {"question": "Is the app free to use, or does it have a subscription plan?", "answer": "No. This app is totally free without any commercial usage."},
      {"question": "What personal data does the app collect?", "answer": "The app collects minimal personal data necessary for functionality, including health tracking information."},
      {"question": "How do I reset my password?", "answer": "You can reset your password in Settings > Account > Reset Password."},
    ],
    "Health and Fitness Tracking": [
      {"question": "What types of health records can I save in the app?", "answer": "You can save records such as weight, water intake, and calorie consumption."},
      {"question": "Can I track my weight, water intake, and calorie consumption?", "answer": "Yes. The app provides tracking for all three."},
      {"question": "Does the app support meal tracking?", "answer": "Yes. The app provides meal tracking."},
      {"question": "Can I set fitness goals within the app?", "answer": "Yes. You can set fitness goals in Profile > Set Target."},
    ],
    "Chatbot Assistance": [
      {"question": "What can the chatbot help me with?", "answer": "It can assist with health and fitness concerns."},
      {"question": "How accurate is the chatbot's fitness advice?", "answer": "The chatbot provides realistic fitness advice, but results may vary per individual."},
      {"question": "Can the chatbot create custom workout or meal plans?", "answer": "No. The chatbot currently does not have that function."},
      {"question": "Does the chatbot provide real-time responses?", "answer": "Yes. The chatbot responds instantly to your queries."},
      {"question": "Can I disable the chatbot if I don't want to use it?", "answer": "No. The chatbot is an essential part of the application."},
    ],
    "Data Privacy": [
      {"question": "Is my health data secure?", "answer": "Yes, we ensure strict security measures to protect your data."},
      {"question": "Can I export or download my health records?", "answer": "No. This feature is currently not available."},
      {"question": "How do I delete my account and remove my data?", "answer": "Go to Settings > Account > Delete Account."},
      {"question": "What happens to my data if I uninstall the app?", "answer": "Your data is stored securely and can be retrieved upon reinstallation."},
      {"question": "Can I restore deleted records?", "answer": "No. The app does not support restoring deleted records."},
    ],
    "Technical Support": [
      {"question": "How do I update the app to the latest version?", "answer": "Update via the Play Store."},
      {"question": "The chatbot is not responding. What should I do?", "answer": "Try restarting the app. If the issue persists, contact support."},
      {"question": "Can I use the app offline?", "answer": "No. Most functionalities require an internet connection."},
      {"question": "How does the chatbot work?", "answer": "It functions similarly to ChatGPT, providing AI-driven responses."},
      {"question": "How do I enable or disable notifications?", "answer": "Adjust notification settings in your phone's settings."},
      {"question": "How do I report a bug or provide feedback?", "answer": "You can provide feedback in More > Provide Feedback."},
    ],
  };

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
          "FAQ",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: faqData.keys.map((category) {
              return ExpansionTile(
                title: Text(category, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                children: faqData[category]!.map((faq) {
                  return ListTile(
                    title: Text(faq["question"]!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(faq["answer"]!, style: TextStyle(fontSize: 16)),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}