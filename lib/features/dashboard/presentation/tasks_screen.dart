import 'package:flutter/material.dart';

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
            SizedBox(height: 4),
            Text(
              "Stay consistent and finish strong 💪",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: getProgress(),
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            //Task List
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 60, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("No tasks yet"),
                          Text(
                            "Add a goal to get started 🚀",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final item = tasks[index];

                        return GestureDetector(
                          onTap: () => onToggle(index),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(vertical: 6),
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: item["done"]
                                  ? Colors.green.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) =>
                                      ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      ),
                                  child: Icon(
                                    item["done"]
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    key: ValueKey(item["done"]),
                                    color: item["done"]
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: AnimatedDefaultTextStyle(
                                    duration: Duration(milliseconds: 300),
                                    style: TextStyle(
                                      fontSize: 15,
                                      decoration: item["done"]
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      color: item["done"]
                                          ? Colors.black54
                                          : Colors.black,
                                    ),
                                    child: Text(item["task"]),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
