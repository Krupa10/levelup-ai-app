import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Center(
          child: Text(
            "LevelUp AI",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SizedBox(height: 20),
                  //progress bar
                  Text("Today's Progress"),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.3, // dummy
                  ),
                  SizedBox(height: 20),
                  //Ask AI coach button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text("Ask AI Coach"),
                    ),
                  ),
                  SizedBox(height: 20),
                  //today's plan
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Plan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("• Revise Flutter basics"),
                        Text("• Build Home Screen UI"),
                        Text("• Practice interview intro"),
                      ],
                    ),
                  ),



                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
