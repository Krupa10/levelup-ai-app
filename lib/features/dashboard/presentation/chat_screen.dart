import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/widgets/section_title.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/chat_message.dart';
import '../../../services/ai_services.dart';
import '../../../widgets/typing_indicator.dart';

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

class _ChatScreen extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  TextEditingController controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    loadChatHistory();
  }

  //for ai API response
  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(role: MessageRole.user, text: text));

      _isTyping = true;
    });

    controller.clear();

    try {
      final response = await AIService.getResponse(text, messages);

      setState(() {
        messages.add(ChatMessage(role: MessageRole.ai, text: response));
      });
    } catch (e) {
      setState(() {
        messages.add(
          ChatMessage(
            role: MessageRole.ai,
            text:
                "⚠️ I couldn't connect right now. Please check your internet and try again.",
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }
  }

  //save history
  Future<void> saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> encodedMessages = messages.map((msg) {
      return jsonEncode(msg.toJson());
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
          return ChatMessage.fromJson(jsonDecode(msg));
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

          //empty state, list view
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.smart_toy_rounded,
                              size: 70,
                              color: Colors.deepPurple,
                            ),

                            SizedBox(height: 16),

                            Text(
                              "Need Career Advice?",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 16),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                "Ask me about Flutter,\nDSA,\nResume Reviews,\nInterviews and Career Growth 🚀",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.all(12),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[messages.length - 1 - index];

                            return Align(
                              alignment: msg.role == MessageRole.user
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: msg.role == MessageRole.user
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  msg.text,
                                  style: TextStyle(
                                    color: msg.role == MessageRole.user
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

                if (_isTyping)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TypingIndicator(),
                    ),
                  ),
              ],
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
