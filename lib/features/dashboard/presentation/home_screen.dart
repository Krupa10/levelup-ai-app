import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/progress_card.dart';
import '../../../services/goal_chip.dart';
import '../../../services/notification_service.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/task_tile.dart';
import '../../../core/theme/app_spacing.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onStreakUpdated;
  final Function(List<Map<String, dynamic>>) onTasksUpdated;

  final List<Map<String, dynamic>> tasks;
  final Function(int) onTaskToggle;

  const HomeScreen({
    super.key,
    required this.onStreakUpdated,
    required this.onTasksUpdated,
    required this.tasks,
    required this.onTaskToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController goalController = TextEditingController();

  int streak = 0;
  bool todayCompleted = false;
  bool isGeneratingPlan = false;
  String currentGoal = "";
  List<Map<String, dynamic>> get todayPlan => widget.tasks;

  //user selected reminder time
  TimeOfDay selectedReminderTime = const TimeOfDay(hour: 9, minute: 0);

  String reminderText = "9:00 AM";

  //goal chips
  final goalTemplates = [
    "Flutter Job",
    "Flutter Interview",
    "DSA",
    "System Design",
    "Portfolio",
    "AI Engineer",
  ];

  // plan generator
  List<Map<String, dynamic>> generatePlan(String goal) {
    goal = goal.toLowerCase();

    List<String> tasks;

    if (goal.contains("flutter interview")) {
      tasks = [
        "Revise Widget Lifecycle",
        "Practice State Management",
        "Solve Flutter Interview Questions",
      ];
    } else if (goal.contains("flutter")) {
      tasks = [
        "Revise Flutter Basics",
        "Build One UI Screen",
        "Read Flutter Documentation",
      ];
    } else if (goal.contains("dsa")) {
      tasks = [
        "Solve 3 Array Problems",
        "Solve 2 String Problems",
        "Revise Time Complexity",
      ];
    } else if (goal.contains("system")) {
      tasks = ["Learn Load Balancing", "Study Caching", "Design URL Shortener"];
    } else if (goal.contains("portfolio")) {
      tasks = [
        "Improve Project UI",
        "Write Project README",
        "Add GitHub Screenshots",
      ];
    } else if (goal.contains("ai")) {
      tasks = [
        "Learn Prompt Engineering",
        "Build AI Mini Project",
        "Read AI Agent Concepts",
      ];
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

  //calculate goal progress
  double calculateGoalProgress() {
    if (todayPlan.isEmpty) return 0;

    int completed = todayPlan.where((task) => task["done"]).length;

    return completed / todayPlan.length;
  }

  //save goal
  Future<void> saveGoal() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("current_goal", currentGoal);
  }

  //load goal
  Future<void> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      currentGoal = prefs.getString("current_goal") ?? "";
    });
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
    HapticFeedback.lightImpact();

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
    loadStreak();
    loadGoal();
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
      appBar: const CustomAppBar(title: "LevelUp AI"),
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

                    Text(
                      currentGoal.isEmpty
                          ? "Set a goal to begin tracking progress 🚀"
                          : currentGoal,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    SizedBox(height: AppSpacing.md),

                    ProgressCard(
                      title: "Goal Progress",
                      progress: calculateGoalProgress(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              //goal chip
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: goalTemplates.map((goal) {
                  return GoalChip(
                    title: goal,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      goalController.text = goal;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.sm),

              // goal input text field
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
                  isLoading: isGeneratingPlan,

                  onPressed: () async {
                    if (goalController.text.trim().isEmpty) return;

                    setState(() {
                      isGeneratingPlan = true;
                    });

                    await Future.delayed(const Duration(milliseconds: 800));

                    setState(() {
                      currentGoal = goalController.text;

                      widget.onTasksUpdated(generatePlan(currentGoal));

                      todayCompleted = false;

                      isGeneratingPlan = false;
                    });
                    FocusScope.of(context).unfocus();
                    goalController.clear();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Plan generated successfully 🚀"),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // plan list
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    todayPlan.isEmpty
                        ? const Center(child: Text("No plan generated yet 🚀"))
                        : ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: todayPlan.map((item) {
                              return TaskTile(
                                title: item["task"],

                                isDone: item["done"],

                                onTap: () {
                                  HapticFeedback.lightImpact();

                                  final index = todayPlan.indexOf(item);

                                  setState(() {
                                    widget.onTaskToggle(index);
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
                                  });
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
