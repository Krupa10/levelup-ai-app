import 'package:flutter/material.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

void main() {
  runApp(const LevelUpAI());
}

class LevelUpAI extends StatelessWidget {
  const LevelUpAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LevelUp AI',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const DashboardScreen(),
    );
  }
}