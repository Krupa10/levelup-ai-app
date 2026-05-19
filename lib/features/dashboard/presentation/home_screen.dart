import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onStreakUpdated;
  final Function(List<Map<String, dynamic>>) onTasksUpdated;

  const HomeScreen({super.key, required this.onStreakUpdated, required this.onTasksUpdated,});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> todayPlan = [];
  TextEditingController goalController = TextEditingController();

  int streak = 0;
  bool todayCompleted = false;

  // plan generator
  List<Map<String, dynamic>> generatePlan(String goal) {
    goal = goal.toLowerCase();

    List<String> tasks;

    if (goal.contains("flutter")) {
      tasks = [
        "Revise Flutter basics",
        "Build one UI screen",
        "Practice interview questions",
      ];
    } else if (goal.contains("job")) {
      tasks = ["Apply to 5 companies", "Improve resume", "Practice DSA"];
    } else {
      tasks = ["Work on your project", "Learn new concept", "Stay consistent"];
    }

    return tasks.map((task) {
      return {"task": task, "done": false};
    }).toList();
  }

  // storage
  Future<void> saveStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("streak", streak);
  }

  Future<void> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      streak = prefs.getInt("streak") ?? 0;
    });

    // send to dashboard
    widget.onStreakUpdated(streak);
  }

  //save plan
  Future<void> savePlan() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> tasks = todayPlan.map((t) => t["task"] as String).toList();
    List<bool> status = todayPlan.map((t) => t["done"] as bool).toList();

    await prefs.setStringList("tasks", tasks);
    await prefs.setStringList(
      "status",
      status.map((e) => e.toString()).toList(),
    );
  }

  //load plan
  Future<void> loadPlan() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? tasks = prefs.getStringList("tasks");
    List<String>? status = prefs.getStringList("status");

    if (tasks != null && status != null) {
      setState(() {
        todayPlan = List.generate(tasks.length, (index) {
          return {
            "task": tasks[index],
            "done": status[index] == "true",
          };
        });
      });
      widget.onTasksUpdated(todayPlan);
    }
  }

  //save history
  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();

    String today = DateTime.now().toString().split(' ')[0];

    List<String> completedTasks = todayPlan
        .where((t) => t["done"])
        .map((t) => t["task"] as String)
        .toList();

    await prefs.setStringList(today, completedTasks);
  }

  // init
  @override
  void initState() {
    super.initState();
    todayPlan = generatePlan("flutter job");
    loadStreak();
    loadPlan();
  }

  // progress
  double getProgress() {
    if (todayPlan.isEmpty) return 0;

    return todayPlan.where((t) => t["done"]).length / todayPlan.length;
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "LevelUp AI",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // streak
            Text(
              "🔥 Streak: $streak days",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (streak > 0) const Text("Keep going! You're consistent 🚀"),
            const SizedBox(height: 16),

            // progress
            const Text("Today's Progress"),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: getProgress(),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),

            // goal input
            TextField(
              controller: goalController,
              decoration: InputDecoration(
                hintText: "Enter your goal (e.g. Flutter job)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // generate plan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  if (goalController.text.trim().isEmpty) return;

                  setState(() {
                    todayPlan = generatePlan(goalController.text);
                    todayCompleted = false;
                  });

                  widget.onTasksUpdated(todayPlan);
                  savePlan();
                  goalController.clear();
                },
                child: const Text("Generate Plan"),
              ),
            ),
            const SizedBox(height: 20),

            // plan list
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Plan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: todayPlan.map((item) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                item["done"] = !item["done"];

                                bool allDoneNow = todayPlan.every(
                                  (t) => t["done"],
                                );

                                if (allDoneNow && !todayCompleted) {
                                  streak++;
                                  todayCompleted = true;

                                  saveStreak();
                                  saveHistory();
                                  widget.onStreakUpdated(streak);
                                }
                                savePlan();
                              });
                              widget.onTasksUpdated(todayPlan);
                            },
                            //checkbox
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: item["done"]
                                    ? Colors.grey.shade200
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      );
                                    },
                                    child: Icon(
                                      item["done"]
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      key: ValueKey(item["done"]),
                                      color: item["done"]
                                          ? Colors.green
                                          : Theme.of(context).textTheme.bodySmall?.color,
                                      size: 26,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      style: TextStyle(
                                        decoration: item["done"]
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        decorationThickness: 2,
                                        decorationColor: Theme.of(context).textTheme.bodyLarge?.color,
                                        color: item["done"]
                                            ? Colors.black54
                                            : Theme.of(context).textTheme.bodyLarge?.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      child: Text(item["task"]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
