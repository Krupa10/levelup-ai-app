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

  @override
  Widget build(BuildContext context) {
    final dates = history.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: history.isEmpty
          ? const Center(child: Text("No history yet"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
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
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                ...tasks.map((task) => Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(task)),
                  ],
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}