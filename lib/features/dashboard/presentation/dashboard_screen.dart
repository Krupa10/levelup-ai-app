import 'package:flutter/material.dart';
import 'package:level_up_ai/features/dashboard/presentation/chat_screen.dart';
import 'package:level_up_ai/features/dashboard/presentation/home_screen.dart';
import 'package:level_up_ai/features/dashboard/presentation/profile_screen.dart';
import 'package:level_up_ai/features/dashboard/presentation/tasks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
