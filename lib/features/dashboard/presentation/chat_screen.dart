import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/widgets/section_title.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

  if (message.contains("flutter")) {
    return """
Flutter Roadmap 🚀

1. Revise Widgets
2. Understand State Management
3. Learn API Integration
4. Practice Local Storage
5. Build Projects
6. Prepare Flutter Interview Questions

Spend at least 2 hours daily.
""";
  }

  if (message.contains("interview")) {
    return """
Flutter Interview Preparation 🎯

• Widget Lifecycle
• Stateless vs Stateful Widgets
• State Management
• Future & Async/Await
• API Integration
• Local Database
• Firebase Basics

Practice explaining concepts aloud.
""";
  }

  if (message.contains("resume")) {
    return """
Resume Improvement Tips 📄

• Add strong project descriptions
• Mention measurable impact
• Highlight Flutter skills
• Add GitHub projects
• Keep resume 1 page

Your AI productivity app should be a featured project.
""";
  }

  if (message.contains("job")) {
    return """
Job Search Strategy 💼

• Apply daily
• Update LinkedIn
• Improve Resume
• Build Portfolio Projects
• Practice Interviews

Consistency beats motivation.
""";
  }

  if (message.contains("motivation")) {
    return """
Motivation Boost 🔥

You don't need motivation every day.

Build systems.
Build habits.
Take action even when you don't feel like it.

Small progress daily wins.
""";
  }

  if (message.contains("plan")) {
    return """
Today's Productivity Plan 📅

1. Flutter Revision
2. Project Development
3. Interview Practice
4. Resume Improvement
5. Apply for Jobs

Focus on completion, not perfection.
""";
  }

  return """
I can help with:

🎯 Flutter
💼 Jobs
📄 Resume
🚀 Career Growth
🔥 Motivation
📅 Daily Planning

Try asking one of these topics.
""";
}

class _ChatScreen extends State<ChatScreen> {
  List<Map<String, String>> messages = [];
  TextEditingController controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  //dummy response
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
    });

    saveChatHistory();
    scrollToBottom();
    controller.clear();

    setState(() {
      messages.add({"role": "ai", "text": "Typing..."});
    });

    saveChatHistory();
    scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        messages.removeLast();

        messages.add({"role": "ai", "text": getDummyResponse(text)});
      });

      saveChatHistory();
      scrollToBottom();
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

  //auto scroll to bottom
  void scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final offset =
          _scrollController.position.maxScrollExtent;

      if (animated) {
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(offset);
      }
    });
  }

  //save history
  Future<void> saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> encodedMessages = messages.map((msg) {
      return jsonEncode(msg);
    }).toList();

    await prefs.setStringList("chat_history", encodedMessages);
  }

  //load history
  Future<void> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? savedMessages = prefs.getStringList("chat_history");

    if (savedMessages != null) {
      setState(() {
        messages = savedMessages.map((msg) {
          return Map<String, String>.from(jsonDecode(msg));
        }).toList();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom(animated: false);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    loadChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Coach")),
      body: Column(
        children: [
          ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SectionTitle(title: "🤖 AI Career Coach"),

                SizedBox(height: AppSpacing.sm),

                Text(
                  "Ask me about Flutter interviews, resume improvement, daily plans, or career growth.",
                ),
              ],
            ),
          ),

          messages.isEmpty
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.smart_toy, size: 60),
                        SizedBox(height: 12),
                        Text(
                          "Need help with interviews,resume or career growth? 🚀",
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];

                      return Align(
                        alignment: msg["role"] == "user"
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth:
                          MediaQuery.of(context).size.width * 0.75),
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: msg["role"] == "user"
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg["text"]!,
                            style: TextStyle(
                              color: msg["role"] == "user"
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

          //prompt chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: prompts.map((prompt) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(prompt),
                      onPressed: () {
                        sendMessage(prompt);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // input field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Theme.of(context).scaffoldBackgroundColor,
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
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      sendMessage(controller.text);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
