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
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:level_up_ai/utils/prompt_mapper.dart';

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
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    loadChatHistory();
  }

  //suggested prompts
  final List<String> suggestedPrompts = [
    "🚀 Create a career roadmap",
    "🧠 Give me productivity tips",
  ];

  //dispose method
  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  //add AI message helper
  void _addEmptyAiMessage() {
    messages.add(ChatMessage(role: MessageRole.ai, text: ""));
  }

  //update last AI message helper
  void _updateLastAiMessage(String text) {
    messages[messages.length - 1] = ChatMessage(
      role: MessageRole.ai,
      text: text,
    );

    setState(() {});
  }

  //scroll to bottom helper
  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        0, // because ListView is reverse:true
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  //for ai API response
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    controller.clear();

    setState(() {
      // Add user's message
      messages.add(ChatMessage(role: MessageRole.user, text: text));

      // Show typing indicator
      _isTyping = true;
    });
    _scrollToBottom();
    try {
      // Get AI response
      final response = await AIService.getResponse(text, messages);

      // Remove typing indicator and add an empty AI bubble
      setState(() {
        _isTyping = false;

        _addEmptyAiMessage();
      });
      _scrollToBottom();

      // Stream into that AI bubble
      await streamResponse(response);
    } catch (e) {
      setState(() {
        _isTyping = false;

        messages.add(
          ChatMessage(
            role: MessageRole.ai,
            text: "⚠️ Something went wrong.\nPlease try again.",
          ),
        );
      });
    }
  }

  //stream response
  Future<void> streamResponse(String response) async {
    String current = "";

    for (int i = 0; i < response.length; i++) {
      await Future.delayed(const Duration(milliseconds: 8));

      if (!mounted) return;

      current += response[i];

      _updateLastAiMessage(current);

      if (i % 12 == 0) {
        _scrollToBottom();
      }
    }

    _scrollToBottom();
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
                      ? EmptyState(
                          icon: Icons.smart_toy_rounded,
                          title: "Need Career Advice?",
                          subtitle:
                              "Ask me anything about your career,\nlearning, interviews,\nresume, productivity or growth.",
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: suggestedPrompts.map((prompt) {
                              return ActionChip(
                                label: Text(prompt),
                                onPressed: () {
                                  sendMessage(PromptMapper.buildPrompt(prompt));
                                },
                              );
                            }).toList(),
                          ),
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
                                child: MarkdownBody(
                                  data: msg.text,
                                  selectable: true,
                                  styleSheet: MarkdownStyleSheet(
                                    p: TextStyle(
                                      color: msg.role == MessageRole.user
                                          ? Colors.white
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
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
                        controller.text = PromptMapper.buildPrompt(prompt);

                        controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.text.length),
                        );
                        _focusNode.requestFocus();
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
                    focusNode: _focusNode,
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
