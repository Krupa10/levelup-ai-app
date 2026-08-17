import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:level_up_ai/services/memory_service.dart';

class DailyCoachService {
  static final GenerativeModel _model = GenerativeModel(
    model: "gemini-2.5-flash",
    apiKey: dotenv.env["GEMINI_API_KEY"]!,
  );

  static const String fallbackMessage =
      "Focus on one important task today and keep your momentum going. 🚀";

  // Save today's AI coach
  static Future<void> saveDailyCoach(String message) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("daily_coach_message", message);

    await prefs.setString("daily_coach_date", DateTime.now().toIso8601String());
  }

  // Get today's cached coach
  static Future<String?> getCachedDailyCoach() async {
    final prefs = await SharedPreferences.getInstance();

    final message = prefs.getString("daily_coach_message");
    final savedDate = prefs.getString("daily_coach_date");

    if (message == null || savedDate == null) {
      return null;
    }

    final savedDateTime = DateTime.tryParse(savedDate);

    if (savedDateTime == null) {
      return null;
    }

    final now = DateTime.now();

    final isSameDay =
        savedDateTime.year == now.year &&
        savedDateTime.month == now.month &&
        savedDateTime.day == now.day;

    if (!isSameDay) {
      return null;
    }

    return message;
  }

  // Get the last saved coach, even if it is from a previous day.
  static Future<String?> getLastCachedDailyCoach() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("daily_coach_message");
  }

  // Clear today's coach when the user creates a new plan.
  static Future<void> clearDailyCoach() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("daily_coach_message");
    await prefs.remove("daily_coach_date");
  }

  // Generate a new AI coach message
  static Future<String> generateDailyCoach({
    required String goal,
    required int completedTasks,
    required int totalTasks,
    required int streak,
  }) async {
    final memory = await MemoryService.getMemory();

    final pendingTasks = totalTasks - completedTasks;

    final prompt =
        '''
You are an intelligent and supportive career coach.

Your job is to give the user a short personalized daily coaching message.

User's current goal:
$goal

Today's progress:
Completed tasks: $completedTasks
Total tasks: $totalTasks
Pending tasks: $pendingTasks

Current streak:
$streak days

Long-term AI memory:
${memory.isEmpty ? "No long-term memory yet." : memory}

Instructions:
- Give practical and personalized advice.
- Focus on what the user should prioritize today.
- Do not invent tasks that are not provided.
- Do not mention that you are an AI.
- Do not repeat the user's goal unnecessarily.
- Keep the response between 40 and 70 words.
- Use a warm, motivating but professional tone.
- Mention the user's progress when relevant.
- End with a short motivating sentence.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      final message = response.text?.trim();

      if (message == null || message.isEmpty) {
        throw Exception("Empty AI response");
      }

      // Only save when Gemini successfully generated a real response.
      await saveDailyCoach(message);

      return message;
    } catch (e) {
      debugPrint("Daily coach generation error: $e");

      // Let HomeScreen decide whether to use previous cache
      // or the default fallback message.
      rethrow;
    }
  }
}
