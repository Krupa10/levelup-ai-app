import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  List<Map<String, dynamic>> todayPlan = [];
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

  TextEditingController goalController = TextEditingController();
  int streak = 0;
  bool completedOnce = false;
  bool todayCompleted = false;

  Future<void> saveStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("streak", streak);
  }

  Future<void> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      streak = prefs.getInt("streak") ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    todayPlan = generatePlan("flutter job");
    loadStreak();
  }

  double getProgress() {
    if (todayPlan.isEmpty) return 0;

    return todayPlan.where((t) => t["done"]).length / todayPlan.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Center(
          child: Text(
            "LevelUp AI",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  //streak UI
                  Text(
                    "🔥 Streak: $streak days",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (streak > 0) Text("Keep going! You're consistent 🚀"),
                  SizedBox(height: 10),
                  SizedBox(height: 20),
                  //progress bar
                  Text("Today's Progress"),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: getProgress(), // dummy
                  ),
                  SizedBox(height: 20),
                  //Ask AI coach button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text("Ask AI Coach"),
                    ),
                  ),
                  SizedBox(height: 20),
                  //goal input field
                  TextField(
                    controller: goalController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Enter your goal (e.g. Flutter job)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  //generate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (goalController.text.trim().isEmpty) return;

                        setState(() {
                          todayPlan = generatePlan(goalController.text);
                          todayCompleted = false;
                        });

                        goalController.clear(); // optional
                      },
                      child: Text("Generate Plan"),
                    ),
                  ),
                  SizedBox(height: 20),
                  //today's plan
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    //plan UI
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Plan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),

                        ...todayPlan.map((item) {
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
                                }
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item["done"]
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: item["done"]
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item["task"],
                                      style: TextStyle(
                                        decoration: item["done"]
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
