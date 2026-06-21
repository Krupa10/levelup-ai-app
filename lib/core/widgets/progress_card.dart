import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final String title;
  final double progress;

  const ProgressCard({super.key, required this.title, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),

        const SizedBox(height: 8),

        LinearProgressIndicator(
          value: progress,
          borderRadius: BorderRadius.circular(10),
        ),

        const SizedBox(height: 8),

        Text("${(progress * 100).toInt()}%"),
      ],
    );
  }
}
