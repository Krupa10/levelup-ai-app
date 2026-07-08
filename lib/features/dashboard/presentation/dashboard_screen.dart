import 'package:flutter/material.dart';
import 'package:level_up_ai/features/dashboard/presentation/chat_screen.dart';
import 'package:level_up_ai/features/dashboard/presentation/home_screen.dart';
import 'package:level_up_ai/features/dashboard/presentation/profile_screen.dart';
import 'package:level_up_ai/features/dashboard/presentation/tasks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/memory_service.dart';

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
  String currentGoal = '';
  List<Map<String, dynamic>> tasks = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //save plan
  Future<void> savePlan() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> taskNames = tasks.map((t) => t["task"] as String).toList();

    List<bool> status = tasks.map((t) => t["done"] as bool).toList();

    await prefs.setStringList("tasks", taskNames);

    await prefs.setStringList(
      "status",
      status.map((e) => e.toString()).toList(),
    );
    await MemoryService.updateMemory(
      goal: currentGoal,
      completedTasks: status.where((e) => e).length,
      totalTasks: tasks.length,
    );
  }

  //load plan
  Future<void> loadPlan() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? taskNames = prefs.getStringList("tasks");
    List<String>? status = prefs.getStringList("status");

    if (taskNames != null && status != null) {
      setState(() {
        tasks = List.generate(taskNames.length, (index) {
          return {"task": taskNames[index], "done": status[index] == "true"};
        });
      });
    }
  }

  //init state
  @override
  void initState() {
    super.initState();
    loadPlan();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        tasks: tasks,

        onTaskToggle: (index) {
          setState(() {
            tasks[index]["done"] = !tasks[index]["done"];
          });

          savePlan();
        },

        onStreakUpdated: (value) {
          setState(() {
            streak = value;
          });
        },

        onTasksUpdated: (updatedTasks) {
          setState(() {
            tasks = updatedTasks;
          });

          savePlan();
        },
      ),

      const ChatScreen(),
      TasksScreen(
        tasks: tasks,
        onToggle: (index) {
          setState(() {
            tasks[index]["done"] = !tasks[index]["done"];
          });

          savePlan();
        },
      ),
      ProfileScreen(
        streak: streak,
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),

          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat),
            label: "Chat",
          ),

          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: "Tasks",
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
