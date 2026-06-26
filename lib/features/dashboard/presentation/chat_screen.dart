import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/widgets/section_title.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/ai_responses.dart';
import '../../../services/ai_services.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

//suggestions
final suggestions = [
  "Flutter Interview",
  "Resume Review",
  "DSA Roadmap",
  "Job Search",
  "Flutter Learning",
  "System Design",
];

//AI response
String getAIResponse(String message) {
  message = message.toLowerCase();

  for (final keyword in AIResponses.responses.keys) {
    if (message.contains(keyword)) {
      return AIResponses.responses[keyword]!;
    }
  }

  return """
I can help with:

• Flutter
• Resume
• Interviews
• Jobs
• DSA
• Career Growth

Try asking a more specific question 🚀
""";
}

class _ChatScreen extends State<ChatScreen> {
  List<Map<String, String>> messages = [];
  TextEditingController controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    loadChatHistory();
  }

  //dummy response
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
    });

    saveChatHistory();
    controller.clear();

    setState(() {
      messages.add({"role": "ai", "text": "Typing..."});
    });

    saveChatHistory();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        messages.removeLast();

        messages.add({"role": "ai", "text": getAIResponse(text)});
      });

      saveChatHistory();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "AI Coach"),
      body: Column(
        children: [
          ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SectionTitle(title: "🤖 AI Career Coach"),

                SizedBox(height: AppSpacing.sm),

                Text(
                  "I can help with Flutter, DSA, interviews,resume reviews and career planning 🚀",
                ),
              ],
            ),
          ),

          messages.isEmpty
              ? EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: "Start chatting",
                  subtitle:
                      "Ask me about Flutter, interviews or career planning.",
                )
              : Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[messages.length - 1 - index];

                      return Align(
                        alignment: msg["role"] == "user"
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
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
                children: suggestions.map((prompt) {
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
