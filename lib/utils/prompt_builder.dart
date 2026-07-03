import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class PromptBuilder {
  static Future<String> buildPrompt({
    required String userMessage,
    required List<ChatMessage> chatHistory,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Goal
    final goal = prefs.getString("current_goal") ?? "Not Set";

    // Tasks
    final taskNames = prefs.getStringList("tasks") ?? [];
    final status = prefs.getStringList("status") ?? [];

    final completedTasks = status.where((e) => e == "true").length;
    final pendingTasks = status.where((e) => e == "false").length;

    // Resume
    final resumePath = prefs.getString("resume_path");
    final hasResume = resumePath != null;

    // Conversation history
    final recentMessages = chatHistory.length > 10
        ? chatHistory.sublist(chatHistory.length - 10)
        : chatHistory;

    final history = recentMessages.length > 1
        ? recentMessages.sublist(0, recentMessages.length - 1)
        : <ChatMessage>[];

    final conversation = history.isEmpty
        ? "No previous conversation."
        : history.map((msg) {
      final role = msg.role == MessageRole.user ? "User" : "AI";
      return "$role: ${msg.text}";
    }).join("\n");

    return '''
          You are LevelUp AI, a friendly and professional AI career coach.
          
          Your role:
          - Help users achieve their career goals.
          - Provide practical and actionable advice.
          - Motivate users positively.
          - Keep responses concise.
          - Use bullet points whenever appropriate.
          Always:
          - Be supportive and encouraging.
          - Give actionable advice.
          - Prefer concise answers unless the user asks for details.
          - Focus on long-term career growth, not just answering the immediate question.
          - Mention the user's goal or progress when it's relevant.
          
          User Information
          
          Career Goal:
          $goal
          
          Total Tasks:
          ${taskNames.length}
          
          Completed Tasks:
          $completedTasks
          
          Pending Tasks:
          $pendingTasks
          
          Resume Uploaded:
          ${hasResume ? "Yes" : "No"}
          
          Recent Conversation:
          $conversation
          
          Current User Question:
          $userMessage
          
          Instructions:
          - Continue the conversation naturally.
          - Don't repeat previous answers.
          - Use the recent conversation when relevant.
          - If there is no previous conversation, answer normally.
          - Be concise but helpful.
          - End with one motivational sentence when appropriate.
                    ''';
  }
}
