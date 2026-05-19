import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/dashboard/presentation/dashboard_screen.dart';

void main() {
  runApp(LevelUpAI());
}

class LevelUpAI extends StatefulWidget {
  const LevelUpAI({super.key});

  @override
  State<LevelUpAI> createState() => _LevelUpAIState();
}

class _LevelUpAIState extends State<LevelUpAI> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("darkMode") ?? false;
    });
  }

  Future<void> toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", value);

    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey.shade100,
        cardColor: Colors.white,
      ),

      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212),
        cardColor: Color(0xFF1E1E1E),
      ),

      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: DashboardScreen(
        onThemeChanged: toggleTheme,
        isDarkMode: isDarkMode,
      ),
    );
  }
}
