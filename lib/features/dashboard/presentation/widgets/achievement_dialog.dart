import 'package:flutter/material.dart';

class AchievementDialog extends StatelessWidget {
  final int streak;

  const AchievementDialog({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("🎉 Congratulations!"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "You completed today's learning plan!",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "🔥 Current Streak: $streak days",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Keep building your future one day at a time 🚀",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Awesome!"),
        ),
      ],
    );
  }
}
