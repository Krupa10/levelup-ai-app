import 'package:flutter/material.dart';

import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../services/resume_service.dart';
import 'history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final int streak;
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.streak,
    required this.isDarkMode,
    required this.onThemeChanged,
  });
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? resumePath;

  String getConsistencyText() {
    if (widget.streak == 0) {
      return "Start your journey 💪";
    }

    if (widget.streak < 3) {
      return "Good start 👍";
    }

    if (widget.streak < 7) {
      return "Improving 🚀";
    }

    return "On fire 🔥";
  }

  @override
  void initState() {
    super.initState();
    loadResume();
  }

  //resume loader
  Future<void> loadResume() async {
    resumePath = await ResumeService.getResume();

    setState(() {});
  }

  //resume name helper
  String getResumeName() {
    if (resumePath == null) {
      return "";
    }

    return resumePath!.split("/").last;
  }

  //get badge
  String getBadge() {
    if (widget.streak >= 30) return "🥇 Gold Achiever";
    if (widget.streak >= 7) return "🥈 Silver Consistency";
    if (widget.streak >= 3) return "🥉 Bronze Starter";

    return "🚀 Beginner";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Profile"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // user info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      child: Icon(Icons.person, size: 35),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Flutter Developer",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text("Target: Product-Based Company"),

                          SizedBox(height: 4),

                          Text("Building consistency every day 🚀"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // streak
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🔥 Current Streak",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${widget.streak} Days",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              //achievement badge
              const SizedBox(height: 20),
              InfoCard(
                title: "Achievement Badge",
                child: Text(
                  getBadge(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              //reward section
              const SizedBox(height: 20),
              InfoCard(
                title: "Next Reward",
                child: Text(
                  widget.streak < 3
                      ? "Reach 3 days for Bronze Badge 🥉"
                      : widget.streak < 7
                      ? "Reach 7 days for Silver Badge 🥈"
                      : widget.streak < 30
                      ? "Reach 30 days for Gold Badge 🥇"
                      : "All rewards unlocked 🎉",
                ),
              ),

              //consistency card
              const SizedBox(height: 20),
              InfoCard(
                title: "Consistency Status",
                child: Text(getConsistencyText()),
              ),

              // resume
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📊 Progress Hub",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    //upload resume button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final path = await ResumeService.pickResume();

                          if (path != null) {
                            setState(() {
                              resumePath = path;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Resume uploaded 🎉"),
                              ),
                            );
                          }
                        },
                        child: const Text("Upload Resume"),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //show uploaded resume, empty state
                    const SizedBox(height: 12),
                    if (resumePath == null)
                      const EmptyState(
                        icon: Icons.description_outlined,
                        title: "No Resume Uploaded",
                        subtitle: "Upload your resume to track and improve it.",
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, color: Colors.red),

                            const SizedBox(width: 12),

                            Expanded(child: Text(getResumeName())),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),

                    //history button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryScreen(),
                            ),
                          );
                        },
                        child: const Text("View History"),
                      ),
                    ),
                  ],
                ),
              ),

              // settings,dark mode
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Settings",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    ListTile(
                      leading: const Icon(Icons.dark_mode),
                      title: const Text("Dark Mode"),
                      trailing: Switch(
                        value: widget.isDarkMode,
                        onChanged: (value) {
                          widget.onThemeChanged(value);
                        },
                      ),
                    ),
                    const ListTile(
                      leading: Icon(Icons.logout),
                      title: Text("Logout"),
                    ),

                    //temporary debug button
                    ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      title: const Text("Clear App Data"),
                      subtitle: const Text("Development only"),
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("All local data cleared"),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
