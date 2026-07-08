import 'package:shared_preferences/shared_preferences.dart';

class MemoryService {
  static const String memoryKey = "ai_memory";

  //save memory
  static Future<void> saveMemory(String memory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(memoryKey, memory);
  }

  //get memory
  static Future<String> getMemory() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(memoryKey) ?? "";
  }

  //update memory
  static Future<void> updateMemory({
    required String goal,
    required int completedTasks,
    required int totalTasks,
  }) async {
    final progress = totalTasks == 0
        ? 0
        : ((completedTasks / totalTasks) * 100).round();

    final summary = '''
      Current Goal:
      $goal
      
      Progress:
      $completedTasks / $totalTasks tasks completed.
      
      Completion:
      $progress%
      
      Last Updated:
      The user recently updated their career plan.
      ''';

    await saveMemory(summary);
  }
}
