import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/widgets/progress_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/stat_card.dart';

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

  //data for chart
  Map<String, int> getWeeklyData() {
    Map<String, int> data = {};

    history.forEach((date, tasks) {
      data[date] = tasks.length;
    });

    return data;
  }

  //manual bar chart
  Widget buildChart() {
    final data = getWeeklyData();
    final dates = data.keys.toList()..sort();

    final recentDates = dates.length > 7
        ? dates.sublist(dates.length - 7)
        : dates;

    int maxTasks = data.values.isEmpty
        ? 1
        : data.values.reduce((a, b) => a > b ? a : b);

    String latestDate = recentDates.isNotEmpty ? recentDates.last : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Weekly Activity 📅",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "Tasks completed in recent days",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: recentDates.map((date) {
            final count = data[date]!;

            double barHeight = (count / maxTasks) * 100;

            bool isLatest = date == latestDate;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔢 VALUE ON TOP
                Text(
                  count.toString(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 6),

                // 📊 BAR
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: barHeight == 0 ? 4 : barHeight, // avoid zero height
                  width: 14,
                  decoration: BoxDecoration(
                    color: isLatest
                        ? Colors
                              .deepPurple // highlight latest
                        : Colors.deepPurple.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),

                SizedBox(height: 6),

                // 📅 DATE LABEL (MM-DD)
                Text(
                  date.substring(5),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  //generate suggestion
  List<String> generateInsights() {
    List<String> insights = [];

    if (history.isEmpty) return insights;

    int totalTasks = 0;
    int totalDays = history.length;

    history.forEach((date, tasks) {
      totalTasks += tasks.length;
    });

    double avgTasks = totalTasks / totalDays;

    // 1-average productivity
    if (avgTasks >= 3) {
      insights.add("🔥 You are highly productive! Keep it up!");
    } else if (avgTasks >= 1) {
      insights.add("👍 Good consistency. Try increasing task count.");
    } else {
      insights.add("🚀 Start small and build consistency.");
    }

    // 2-best day
    int maxTasks = 0;
    String bestDay = "";

    history.forEach((date, tasks) {
      if (tasks.length > maxTasks) {
        maxTasks = tasks.length;
        bestDay = date;
      }
    });

    if (bestDay.isNotEmpty) {
      insights.add("📅 Your best day was $bestDay with $maxTasks tasks!");
    }

    // 3-consistency check
    if (totalDays >= 5) {
      insights.add("💪 You're building a strong habit!");
    }

    return insights;
  }

  //completion rate
  double getCompletionRate() {
    if (history.isEmpty) return 0;

    int totalCompleted = 0;

    for (var day in history.values) {
      totalCompleted += day.length;
    }

    return totalCompleted / (history.length * 3);
  }

  @override
  Widget build(BuildContext context) {
    final dates = history.keys.toList()..sort((a, b) => b.compareTo(a));
    final analytics = calculateAnalytics();
    final insights = generateInsights();

    return Scaffold(
      appBar: const CustomAppBar(title: "History"),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history, size: 70),
                  SizedBox(height: 12),
                  Text("Complete today's tasks and build your streak."),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //AI-insights
                    InfoCard(
                      title: "AI Insights 🤖",
                      child: Column(
                        children: insights
                            .map(
                              (text) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.orange
                                      : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(text),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    buildChart(),

                    const SizedBox(height: 24),

                    //productivity score card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "📈 Productivity Score",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 12),

                          ProgressCard(
                            title: "Completion Rate",
                            progress: getCompletionRate(),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "${(getCompletionRate() * 100).toInt()}% Completion Rate",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // analytics section
                    const Text(
                      "📊 Performance Overview",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    //chart
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: "Total Tasks",
                            value: analytics["totalTasks"].toString(),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: StatCard(
                              title: "Days Active",
                              value: analytics["totalDays"].toString(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: StatCard(
                        title: "Best Day",
                        value:
                            "${analytics["bestDay"]} (${analytics["bestDayCount"]} tasks)",
                      ),
                    ),

                    SizedBox(height: 20),

                    //history
                    SectionTitle(title: "📚 History Timeline"),

                    const SizedBox(height: 20),

                    // history list scrollable
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dates.length,
                      itemBuilder: (context, index) {
                        final date = dates[index];
                        final tasks = history[date]!;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ModernCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // date
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      date,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // tasks
                                ...tasks.map(
                                  (task) => Row(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(task)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
