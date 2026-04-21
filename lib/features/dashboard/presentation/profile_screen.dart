import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //user info
            Row(
              children: [
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
                    Text("Target: 20 LPA Job"),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),

            //streak progress
            Text(
              "🔥 Current Streak: 3 days",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Text("Consistency Level: Improving 🚀"),
            SizedBox(height: 30),

            //resume section UI
            Text(
              "Resume",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            ElevatedButton(onPressed: () {}, child: Text("Upload Resume")),
            SizedBox(height: 20),

            //setting section
            Text(
              "Settings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text("Dark Mode"),
              trailing: Switch(value: false, onChanged: (v) {}),
            ),

            ListTile(leading: Icon(Icons.logout), title: Text("Logout")),
          ],
        ),
      ),
    );
  }
}
