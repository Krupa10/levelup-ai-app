import 'package:flutter/material.dart';
import 'package:level_up_ai/features/dashboard/presentation/widgets/coach_tip_card.dart';
import 'package:level_up_ai/features/dashboard/presentation/widgets/current_goal_card.dart';
import 'package:level_up_ai/features/dashboard/presentation/widgets/greeting_section.dart';
import 'package:level_up_ai/features/dashboard/presentation/widgets/reminder_card.dart';
import 'package:level_up_ai/features/dashboard/presentation/widgets/task_plan_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../services/ai_services.dart';
import '../../../services/goal_chip.dart';
import '../../../services/notification_service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/section_title.dart';
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
  String reminderText = "9:00 AM";
  String coachTip =
      "Complete one important task today before checking social media.";

  List<String> goalSuggestions = [
    "Flutter Job",
    "Flutter Interview",
    "DSA",
    "System Design",
    "Portfolio",
    "AI Engineer",
  ];

  //user selected reminder time
  TimeOfDay selectedReminderTime = const TimeOfDay(hour: 9, minute: 0);

  //helper method
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning ☀️';
    } else if (hour < 17) {
      return 'Good Afternoon 🌤️';
    } else {
      return 'Good Evening 🌙';
    }
  }

  String getMotivation() {
    if (currentGoal.isEmpty) {
      return 'Set a goal and let LevelUp AI guide your journey.';
    }
    final completed = widget.tasks.where((t) => t['done'] == true).length;
    final total = widget.tasks.length;
    if (total == 0) {
      return 'Start by creating your first task.';
    }
    final progress = ((completed / total) * 100).round();
    if (progress >= 80) {
      return 'You are almost there! Finish strong. 🚀';
    } else if (progress >= 50) {
      return 'Great progress! Keep the momentum going. 💪';
    } else {
      return 'Small consistent steps lead to big results. 🌱';
    }
  }

  //goal chips
  final goalTemplates = [
    "Flutter Job",
    "Flutter Interview",
    "DSA",
    "System Design",
    "Portfolio",
    "AI Engineer",
  ];

  //load goal suggestion
  Future<void> loadGoalSuggestions() async {
    if (currentGoal.trim().isEmpty) return;

    try {
      final suggestions = await AIService.generateGoalSuggestions(currentGoal);

      if (!mounted) return;

      setState(() {
        goalSuggestions = suggestions;
      });
    } catch (e) {
      debugPrint("Goal suggestion error: $e");
    }
  }

  //load coach tip
  Future<void> loadCoachTip() async {
    if (currentGoal.isEmpty) return;

    try {
      final completed = widget.tasks.where((t) => t["done"] == true).length;

      final tip = await AIService.generateCoachTip(
        goal: currentGoal,
        completed: completed,
        total: widget.tasks.length,
        streak: streak,
      );

      if (!mounted) return;

      setState(() {
        coachTip = tip;
      });
    } catch (e) {
      debugPrint("Coach Tip Error: $e");
    }
  }

  // plan generator
  Future<List<Map<String, dynamic>>> generatePlan(String goal) async {
    final generatedTasks = await AIService.generatePlan(goal);

    return generatedTasks.map((task) => {"task": task, "done": false}).toList();
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
    if (widget.tasks.isEmpty) return 0;

    final completed = widget.tasks.where((task) => task["done"] == true).length;

    return completed / widget.tasks.length;
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

    List<String> completedTasks = widget.tasks
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
              //motivation card
              GreetingSection(
                greeting: getGreeting(),
                motivation: getMotivation(),
              ),
              const SizedBox(height: 20),

              //coach tip
              CoachTipCard(coachTip: coachTip),
              const SizedBox(height: 16),

              // streak
              SectionTitle(title: "🔥 Streak: $streak days"),
              if (streak > 0)
                SectionTitle(title: "Keep going! You're consistent 🚀"),
              const SizedBox(height: AppSpacing.md),

              // current goal, progress card
              CurrentGoalCard(
                goal: currentGoal,
                progress: calculateGoalProgress(),
              ),

              //goal chip
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: goalSuggestions.map((goal) {
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

                    FocusScope.of(context).unfocus();

                    setState(() {
                      isGeneratingPlan = true;
                    });

                    currentGoal = goalController.text;

                    final newTasks = await generatePlan(currentGoal);

                    widget.onTasksUpdated(newTasks);

                    await loadGoalSuggestions();

                    await loadCoachTip();

                    await saveGoal();

                    goalController.clear();

                    if (!mounted) return;

                    setState(() {
                      todayCompleted = false;
                      isGeneratingPlan = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Plan Generated 🚀"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // plan list
              TaskPlanCard(
                tasks: widget.tasks,
                onTaskTap: (index) {
                  setState(() {
                    widget.onTaskToggle(index);

                    final allDoneNow = widget.tasks.every(
                      (task) => task["done"],
                    );

                    if (allDoneNow && !todayCompleted) {
                      streak++;

                      todayCompleted = true;

                      saveStreak();

                      saveHistory();

                      widget.onStreakUpdated(streak);
                    }
                  });
                },
              ),

              //reminder UI card
              const SizedBox(height: AppSpacing.md),
              ReminderCard(
                reminderText: reminderText,
                onPressed: pickReminderTime,
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
