import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/notification_service.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/task_tile.dart';
import '../../../core/theme/app_spacing.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onStreakUpdated;
  final Function(List<Map<String, dynamic>>) onTasksUpdated;

  const HomeScreen({
    super.key,
    required this.onStreakUpdated,
    required this.onTasksUpdated,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> todayPlan = [];
  TextEditingController goalController = TextEditingController();

  int streak = 0;
  bool todayCompleted = false;
  String currentGoal = "";
  double goalProgress = 0;

  //user selected reminder time
  TimeOfDay selectedReminderTime = const TimeOfDay(hour: 9, minute: 0);

  String reminderText = "9:00 AM";

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
          return {"task": tasks[index], "done": status[index] == "true"};
        });
      });
      widget.onTasksUpdated(todayPlan);
    }
  }

  //calculate goal progress
  double calculateGoalProgress() {
    if (todayPlan.isEmpty) return 0;

    int completed = todayPlan.where((task) => task["done"]).length;

    return completed / todayPlan.length;
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

  //time picker function
  Future<void> pickReminderTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedReminderTime,
    );

    if (pickedTime == null) return;

    // Smart reminder validation
    if (pickedTime.hour < 6 || pickedTime.hour > 23) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Choose a healthier reminder time 😊")),
      );

      return;
    }

    setState(() {
      selectedReminderTime = pickedTime;

      reminderText = pickedTime.format(context);
    });

    // Schedule notification
    await NotificationService.scheduleCustomReminder(
      pickedTime.hour,
      pickedTime.minute,
    );

    // Success popup
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Reminder set for $reminderText 🔔")),
    );
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // streak
              SectionTitle(title: "🔥 Streak: $streak days"),
              if (streak > 0)
                SectionTitle(title: "Keep going! You're consistent 🚀"),
              const SizedBox(height: AppSpacing.md),

              // progress
              SectionTitle(title: "Today's Progress"),
              const SizedBox(height: AppSpacing.xs),

              //calculated progress
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: "🎯 Current Goal"),
                    SizedBox(height: AppSpacing.md),

                    SectionTitle(
                      title: currentGoal.isEmpty
                          ? "No goal set yet"
                          : currentGoal,
                    ),
                    SizedBox(height: AppSpacing.md),

                    LinearProgressIndicator(
                      value: goalProgress,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    SizedBox(height: AppSpacing.md),
                    SectionTitle(
                      title: "${(goalProgress * 100).toInt()}% Completed",
                    ),
                  ],
                ),
              ),

              LinearProgressIndicator(
                value: getProgress(),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

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
              const SizedBox(height: AppSpacing.md),

              // generate plan
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Generate Plan",
                  onPressed: () {
                    if (goalController.text.trim().isEmpty) return;

                    setState(() {
                      currentGoal = goalController.text;

                      todayPlan = generatePlan(currentGoal);

                      goalProgress = 0;
                      todayCompleted = false;
                    });

                    widget.onTasksUpdated(todayPlan);
                    savePlan();
                    goalController.clear();
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // plan list
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: "Today's Plan"),
                    const SizedBox(height: AppSpacing.md),

                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: todayPlan.map((item) {
                        return TaskTile(
                          title: item["task"],

                          isDone: item["done"],

                          onTap: () {
                            setState(() {
                              // toggle task
                              item["done"] = !item["done"];

                              // check if all tasks completed
                              bool allDoneNow = todayPlan.every(
                                (t) => t["done"],
                              );

                              // streak update
                              if (allDoneNow && !todayCompleted) {
                                streak++;

                                todayCompleted = true;

                                saveStreak();

                                saveHistory();

                                widget.onStreakUpdated(streak);
                              }

                              // save updated task state
                              savePlan();

                              // update goal progress
                              goalProgress = calculateGoalProgress();
                            });

                            // update task screen
                            widget.onTasksUpdated(todayPlan);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              //reminder UI card
              const SizedBox(height: AppSpacing.md),
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: "🔔 Daily Reminder"),

                    const SizedBox(height: AppSpacing.md),

                    SectionTitle(title: "Reminder Time: $reminderText"),

                    const SizedBox(height: AppSpacing.md),

                    CustomButton(
                      text: "Change Reminder Time",
                      onPressed: pickReminderTime,
                    ),
                  ],
                ),
              ),

              /*  //notification button
              CustomButton(
                text: "Test Notification",
                onPressed: () {
                  NotificationService.showNotification();
                },
              ),

              //scheduled notification
              CustomButton(
                text: "Schedule Notification",
                onPressed: () {
                  NotificationService.scheduleNotification();
                },
              ),

              //daily motivational reminder
              CustomButton(
                text: "Schedule Notification",
                onPressed: () {
                  NotificationService.scheduleNotification();
                },
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
