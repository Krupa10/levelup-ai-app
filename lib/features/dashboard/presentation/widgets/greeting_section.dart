import 'package:flutter/material.dart';

class GreetingSection extends StatelessWidget {
  final String greeting;
  final String motivation;

  const GreetingSection({
    super.key,
    required this.greeting,
    required this.motivation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(motivation, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
