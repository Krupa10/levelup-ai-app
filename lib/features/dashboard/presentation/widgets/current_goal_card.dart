import 'package:flutter/material.dart';
import 'package:level_up_ai/core/widgets/modern_card.dart';
import 'package:level_up_ai/core/widgets/progress_card.dart';
import 'package:level_up_ai/core/widgets/section_title.dart';

import '../../../../core/theme/app_spacing.dart';

class CurrentGoalCard extends StatelessWidget {
  final String goal;
  final double progress;

  const CurrentGoalCard({
    super.key,
    required this.goal,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "🎯 Current Goal"),

          const SizedBox(height: AppSpacing.md),

          Text(
            goal.isEmpty
                ? "Set a goal to begin your learning journey 🚀"
                : goal,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          if (goal.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),

            ProgressCard(
              title: "Goal Progress",
              progress: progress,
            ),
          ],
        ],
      ),
    );
  }
}