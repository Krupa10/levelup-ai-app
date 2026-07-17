import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:level_up_ai/core/widgets/empty_state.dart';
import 'package:level_up_ai/core/widgets/modern_card.dart';
import 'package:level_up_ai/core/widgets/task_tile.dart';

class TaskPlanCard extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final ValueChanged<int> onTaskTap;

  const TaskPlanCard({super.key, required this.tasks, required this.onTaskTap});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: tasks.isEmpty
          ? const EmptyState(
              icon: Icons.flag_outlined,
              title: "No Plan Generated",
              subtitle:
                  "Choose a career goal above and generate your personalized learning plan.",
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return TaskTile(
                  title: task["task"],
                  isDone: task["done"],
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTaskTap(index);
                  },
                );
              },
            ),
    );
  }
}
