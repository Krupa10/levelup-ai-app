import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/dashboard/presentation/dashboard_screen.dart';
import 'package:level_up_ai/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/theme/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService.initialize();

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

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
      isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,

      home: DashboardScreen(
        onThemeChanged: toggleTheme,
        isDarkMode: isDarkMode,
      ),
    );
  }
}
