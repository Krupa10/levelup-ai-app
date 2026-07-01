import 'package:shared_preferences/shared_preferences.dart';

class PromptBuilder {
  static Future<String> buildPrompt({required String userMessage}) async {
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
          
          User Question:
          $userMessage
          ''';
  }
}
