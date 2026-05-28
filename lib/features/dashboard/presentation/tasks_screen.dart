import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/task_tile.dart';

class TasksScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final Function(int) onToggle;

  const TasksScreen({super.key, required this.tasks, required this.onToggle});

  double getProgress() {
    if (tasks.isEmpty) return 0;
    return tasks.where((t) => t["done"]).length / tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Tasks",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              "Stay consistent and finish strong 💪",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            //Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Progress"),
                    Text("${(getProgress() * 100).toInt()}%"),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                  child: LinearProgressIndicator(
                    value: getProgress(),
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            //Task List
            Expanded(
              child: tasks.isEmpty
                  ? EmptyState(message: "No tasks added yet")
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final item = tasks[index];

                        return TaskTile(
                          title: item["task"],

                          isDone: item["done"],

                          onTap: () {
                            onToggle(index);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
