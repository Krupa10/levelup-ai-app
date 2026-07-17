import 'package:flutter/material.dart';
import 'package:level_up_ai/core/widgets/custom_button.dart';
import 'package:level_up_ai/core/widgets/modern_card.dart';
import 'package:level_up_ai/core/widgets/section_title.dart';

import '../../../../core/theme/app_spacing.dart';

class ReminderCard extends StatelessWidget {
  final String reminderText;
  final VoidCallback onPressed;

  const ReminderCard({
    super.key,
    required this.reminderText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "🔔 Daily Reminder"),

          const SizedBox(height: AppSpacing.md),

          SectionTitle(title: "Reminder Time: $reminderText"),

          const SizedBox(height: AppSpacing.md),

          CustomButton(text: "Change Reminder Time", onPressed: onPressed),
        ],
      ),
    );
  }
}
