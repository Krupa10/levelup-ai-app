import 'package:flutter/material.dart';

import '../../../services/ai_services.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreen();
}
final List<String> prompts = [
  "Prepare for interview",
  "Improve my resume",
  "Create daily plan",
];
String getDummyResponse(String message) {
  message = message.toLowerCase();

  if (message.contains("interview")) {
    return "Start with Flutter basics, revise state management, and practice common interview questions daily.";
  } else if (message.contains("resume")) {
    return "Focus on highlighting your projects, especially your AI app, and use strong action words.";
  } else if (message.contains("plan")) {
    return "Today's plan: 1. Flutter revision 2. Build feature 3. Practice interview.";
  } else {
    return "I'm here to help you improve your career. Ask me about interviews, resume, or daily plan.";
  }
}

class _ChatScreen extends State<ChatScreen> {
  List<Map<String, String>> messages = [];
  TextEditingController controller = TextEditingController();


  //dummy response
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "role": "user",
        "text": text,
      });
    });

    controller.clear();

    setState(() {
      messages.add({
        "role": "ai",
        "text": "Typing...",
      });
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        messages.removeLast();
        messages.add({
          "role": "ai",
          "text": getDummyResponse(text),
        });
      });
    });
  }
  /*//for ai API response
  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "role": "user",
        "text": text,
      });
    });

    controller.clear();

    // Show typing
    setState(() {
      messages.add({
        "role": "ai",
        "text": "Typing...",
      });
    });

    try {
      final response = await AIService.getResponse(text);

      setState(() {
        messages.removeLast();
        messages.add({
          "role": "ai",
          "text": response,
        });
      });
    } catch (e) {
      setState(() {
        messages.removeLast();
        messages.add({
          "role": "ai",
          "text": "Something went wrong. Try again.",
        });
      });
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Coach")),
      body: Column(
        children: [
          // messages
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                return Align(
                  alignment: msg["role"] == "user"
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: msg["role"] == "user"
                          ? Colors.blue
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(
                        color: msg["role"] == "user"
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          //prompt chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: prompts.map((prompt) {
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: prompts.map((prompt) {
                        return Container(
                          margin: EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              sendMessage(prompt);
                            },
                            child: Text(prompt),
                          ),
                        );
                      }).toList(),
                    ),
                  ) /*ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      // later we’ll use this
                    },
                    child: Text(prompt),
                  ),*/,
                );
              }).toList(),
            ),
          ),
          // input field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Ask something...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                //send button
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(controller.text);
                    controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
