import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, List<String>> history = {};

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final keys = prefs.getKeys();

    Map<String, List<String>> temp = {};

    for (var key in keys) {
      // Only pick date keys (simple filter)
      if (key.contains("-")) {
        final tasks = prefs.getStringList(key);
        if (tasks != null && tasks.isNotEmpty) {
          temp[key] = tasks;
        }
      }
    }

    setState(() {
      history = temp;
    });
  }

  //analytics logic
  Map<String, dynamic> calculateAnalytics() {
    int totalTasks = 0;
    int bestDayCount = 0;
    String bestDay = "";
    int totalDays = history.length;

    history.forEach((date, tasks) {
      totalTasks += tasks.length;

      if (tasks.length > bestDayCount) {
        bestDayCount = tasks.length;
        bestDay = date;
      }
    });

    return {
      "totalTasks": totalTasks,
      "bestDay": bestDay,
      "bestDayCount": bestDayCount,
      "totalDays": totalDays,
    };
  }

  //build card
  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dates = history.keys.toList()..sort((a, b) => b.compareTo(a));
    final analytics = calculateAnalytics();

    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: history.isEmpty
          ? const Center(child: Text("No history yet"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // analytics section
                  Text(
                    "Your Analytics 📊",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Total Tasks",
                          analytics["totalTasks"].toString(),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          "Days Active",
                          analytics["totalDays"].toString(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  _buildStatCard(
                    "Best Day",
                    "${analytics["bestDay"]} (${analytics["bestDayCount"]} tasks)",
                  ),

                  SizedBox(height: 20),

                  // history list scrollable
                  Expanded(
                    child: ListView.builder(
                      itemCount: dates.length,
                      itemBuilder: (context, index) {
                        final date = dates[index];
                        final tasks = history[date]!;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // date
                              Text(
                                date,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // tasks
                              ...tasks.map(
                                (task) => Row(
                                  children: [
                                    const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(task)),
                                  ],
                                ),
                              ),
                            ],
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
