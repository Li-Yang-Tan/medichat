import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medichat/Chat/ChatDatabase.dart';

class ChatService {
  static const MethodChannel _channel = MethodChannel('chat');

  static Future<String> sendMessageToOpenAI(String message) async {
    try {
      final String response = await _channel.invokeMethod('sendMessageToOpenAI', {'message': message});
      return response;
    } on PlatformException catch (e) {
      return "Failed to get response: ${e.message}";
    }
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = []; // Store chat messages
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // Load chat messages from database
  Future<void> _loadMessages() async {
    final loadedMessages = await ChatDatabase.instance.getMessages();
    setState(() {
      messages = loadedMessages;
    });

    // Scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // Function to handle sending message and receiving response from OpenAI
  void sendMessage() async {
    String message = _controller.text;
    if (message.isEmpty) {
      return;
    }

    // Add user message to the chat and save to database
    setState(() {
      messages.add({"sender": "user", "message": message});
      _controller.clear();
    });

    await ChatDatabase.instance.insertMessage("user", message);

    // Scroll to the bottom of the chat
    _scrollToBottom();

    // Show a loading message while waiting for response
    String aiResponse = "Sending message...";

    setState(() {
      messages.add({"sender": "ai", "message": aiResponse});
    });

    // Get response from OpenAI using the method channel
    String response = await ChatService.sendMessageToOpenAI(message);

    setState(() {
      // Replace the loading message with the actual response
      messages[messages.length - 1] = {"sender": "ai", "message": response};
    });

    await ChatDatabase.instance.insertMessage("ai", response);

    // Scroll to the bottom of the chat after receiving the response
    _scrollToBottom();
  }

  // Function to scroll to the bottom of the chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 246, 233),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isUserMessage = messages[index]["sender"] == "user";
                  return Align(
                    alignment:
                    isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Material(
                        color: isUserMessage ? Color.fromARGB(255, 133, 169, 143) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            messages[index]["message"]!,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: "Type a message...",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                      onSubmitted: (message) => sendMessage(),
                      onTap: () {
                        Future.delayed(Duration(milliseconds: 100), () {
                          _scrollToBottom();
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send,
                        color: Color.fromARGB(255, 82, 91, 68)),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
