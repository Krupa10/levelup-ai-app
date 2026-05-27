import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  final double fontSize;

  const SectionTitle({
    super.key,
    required this.title,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,

      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}