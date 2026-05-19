import 'package:flutter/material.dart';

import 'history_screen.dart';

class ProfileScreen extends StatelessWidget {
  final int streak;
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.streak,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  String getConsistencyText() {
    if (streak == 0) return "Start your journey 💪";
    if (streak < 3) return "Good start 👍";
    if (streak < 7) return "Improving 🚀";
    return "On fire 🔥";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // user info
              Row(
                children: const [
                  CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Name",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Flutter Developer"),
                      Text("Target: Product-based company"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // streak
              Text(
                "🔥 Current Streak: $streak days",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Text(getConsistencyText()),
              const SizedBox(height: 30),

              // resume
              const Text(
                "Resume",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {},
                child: const Text("Upload Resume"),
              ),
              const SizedBox(height: 20),

              //history button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
                child: Text("View History"),
              ),

              // settings
              const Text(
                "Settings",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text("Dark Mode"),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    onThemeChanged(value);
                  },
                ),
              ),

              const ListTile(
                leading: Icon(Icons.logout),
                title: Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
