import 'package:flutter/material.dart';
import 'package:level_up_ai/core/widgets/modern_card.dart';
import 'package:level_up_ai/core/widgets/section_title.dart';

import '../../../../core/theme/app_spacing.dart';

class CoachTipCard extends StatelessWidget {
  final String coachTip;

  const CoachTipCard({super.key, required this.coachTip});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "💡 AI Coach Tip"),

          const SizedBox(height: AppSpacing.sm),

          Text(coachTip, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
