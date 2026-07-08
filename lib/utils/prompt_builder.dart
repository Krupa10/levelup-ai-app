import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/ai_personality.dart';
import '../services/memory_service.dart';

class PromptBuilder {
  static Future<String> buildPrompt({
    required String userMessage,
    required List<ChatMessage> chatHistory,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final aiMemory = await MemoryService.getMemory();
    final personality = AIPersonality.careerCoach;

    // Goal
    final goal = prefs.getString("current_goal") ?? "Not Set";

    // Tasks
    final taskNames = prefs.getStringList("tasks") ?? [];
    final status = prefs.getStringList("status") ?? [];

    final completedTasks = status.where((e) => e == "true").length;
    final pendingTasks = status.where((e) => e == "false").length;

    final totalTasks = taskNames.length;
    //tasks summary
    final tasksSummary = taskNames.isEmpty
        ? "No tasks created yet."
        : taskNames.asMap().entries.map((entry) {
      final index = entry.key;
      final task = entry.value;
      final isCompleted =
          index < status.length && status[index] == "true";

      return "${isCompleted ? "✅" : "⬜"} $task";
    }).join("\n");

    final progress = totalTasks == 0
        ? 0
        : ((completedTasks / totalTasks) * 100).round();

    //progress summary
    String progressSummary;

    if (totalTasks == 0) {
      progressSummary =
          "The user hasn't created a plan yet. Encourage them to create one.";
    } else if (progress >= 80) {
      progressSummary =
          "The user is close to achieving the current goal. Encourage them to finish strong and prepare for the next milestone.";
    } else if (progress >= 50) {
      progressSummary =
          "The user is making steady progress. Motivate them to stay consistent.";
    } else {
      progressSummary =
          "The user is still in the early stages of the journey. Focus on building habits and consistency.";
    }

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
        : history
              .map((msg) {
                final role = msg.role == MessageRole.user ? "User" : "AI";
                return "$role: ${msg.text}";
              })
              .join("\n");
    final systemSection = personality.systemPrompt;
    final userSection =
        '''
          User Information
          
          Career Goal:
          $goal
          
          Current Learning Plan (generated inside LevelUp AI):
          
          $tasksSummary
          
          Total Tasks:
          $totalTasks
          
          Completed Tasks:
          $completedTasks
          
          Pending Tasks:
          $pendingTasks
          
          Resume Uploaded:
          ${hasResume ? "Yes" : "No"}
          ''';

    final progressSection =
        '''
          Career Progress Analysis
          
          Progress:
          $progress%
          
          $progressSummary
          ''';

    final memorySection =
        '''
          AI Memory
          
          ${aiMemory.isEmpty ? "No long-term memory yet." : aiMemory}
          ''';

    final conversationSection =
        '''
          Recent Conversation
          
          $conversation
          ''';

    final questionSection =
        '''
          Current User Question
          
          $userMessage
          ''';
    return '''
          $systemSection
          
          $userSection
          
          $progressSection
          
          $memorySection
          
          $conversationSection
          
          $questionSection
          
          Instructions:

        - Continue the conversation naturally.
        - Don't repeat previous answers.
        - Use the recent conversation when relevant.
        - Personalize every response.
        - Always consider the user's goal, learning plan, completed tasks, pending tasks and AI memory before answering.
        - If the question relates to the user's career goal, refer to the current learning plan.
        - Appreciate completed tasks when relevant.
        - Recommend the next pending task instead of suggesting random topics.
        - Avoid suggesting tasks that are already completed.
        - Be concise but helpful.
        - End with one motivational sentence when appropriate.
                    ''';

  }
}
