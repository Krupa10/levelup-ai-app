import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/prompt_builder.dart';
import '../models/chat_message.dart';

class AIService {
  static final model = GenerativeModel(
    model: "gemini-2.5-flash",
    apiKey: dotenv.env["GEMINI_API_KEY"]!,
  );

  //prompt → the user's original message.
  //fullPrompt → the enriched prompt sent to Gemini.

  static Future<String> getResponse(
    String userMessage,
    List<ChatMessage> chatHistory,
  ) async {
    try {
      final fullPrompt = await PromptBuilder.buildPrompt(
        userMessage: userMessage,
        chatHistory: chatHistory,
      );
      print("API KEY: ${dotenv.env["GEMINI_API_KEY"]}");
      final content = [Content.text(fullPrompt)];

      final response = await model.generateContent(content);

      return response.text ?? "Sorry, I couldn't generate a response.";
    } catch (e, stackTrace) {
      debugPrint("========== AI ERROR ==========");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

      return e.toString();
    }
  }

  static Future<List<String>> generatePlan(String goal) async {
    final prompt =
        ''' Create a practical step-by-step learning plan for this goal: $goal Requirements: - Return exactly 6 short tasks. - Each task should be actionable. - One task per line. - Do not use numbering. - Do not add explanations. ''';
    final response = await getResponse(prompt, const []);
    final tasks = response
        .split('\n')
        .map((e) => e.replaceAll(RegExp(r'^[-•*\d.\s]+'), '').trim())
        .where((e) => e.isNotEmpty)
        .take(6)
        .toList();
    return tasks;
  }

  static Future<List<String>> generateGoalSuggestions(String goal) async {
    final prompt =
        """
      You are an expert career coach.
      
      The user's career goal is:
      
      $goal
      
      Suggest exactly 6 short learning topics or milestones related to this goal.
      
      Rules:
      - Maximum 3 words each
      - No numbering
      - No explanations
      - One suggestion per line
      
      Example:
      
      Flutter Interview
      State Management
      Firebase
      Portfolio
      Projects
      Clean Architecture
      """;

    final response = await model.generateContent([Content.text(prompt)]);

    final text = response.text ?? "";

    return text
        .split("\n")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static Future<String> generateCoachTip({
    required String goal,
    required int completed,
    required int total,
    required int streak,
  }) async {
    final prompt =
        """
      You are an encouraging career coach.
      
      User Goal:
      $goal
      
      Completed Tasks:
      $completed
      
      Total Tasks:
      $total
      
      Current Streak:
      $streak days
      
      Write ONE short personalized coaching tip.
      
      Rules:
      - Maximum 15 words.
      - One sentence only.
      - Friendly.
      - Motivational.
      - Practical.
      - Do not greet the user.
      - Do not use bullet points.
      """;

    final response = await model.generateContent([Content.text(prompt)]);

    return response.text?.trim() ??
        "Stay consistent. Every small step brings you closer to your goal.";
  }
}
