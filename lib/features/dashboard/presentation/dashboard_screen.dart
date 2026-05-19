import 'package:flutter/material.dart';
import 'package:level_up_ai/features/dashboard/presentation/chat_screen.dart';
import 'package:level_up_ai/features/dashboard/presentation/home_screen.dart';
import 'package:level_up_ai/features/dashboard/presentation/profile_screen.dart';
import 'package:level_up_ai/features/dashboard/presentation/tasks_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const DashboardScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int streak = 0;
  int _selectedIndex = 0;
  List<Map<String, dynamic>> tasks = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onStreakUpdated: (value) {
          setState(() {
            streak = value;
          });
        },
        onTasksUpdated: (updatedTasks) {
          setState(() {
            tasks = updatedTasks;
          });
        },
      ),

      const ChatScreen(),
      TasksScreen(
        tasks: tasks,
        onToggle: (index) {
          setState(() {
            tasks[index]["done"] = !tasks[index]["done"];
          });
        },
      ),
      ProfileScreen(
        streak: streak,
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Tasks",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
