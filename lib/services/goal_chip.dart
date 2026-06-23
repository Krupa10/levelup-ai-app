import 'package:flutter/material.dart';

class GoalChip extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const GoalChip({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(title), onPressed: onTap);
  }
}
