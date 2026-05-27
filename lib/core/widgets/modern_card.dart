import 'package:flutter/material.dart';

class ModernCard extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry? padding;

  final Color? color;

  final double borderRadius;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding:
      padding ??
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color:
        color ??
            Theme.of(context).cardColor,

        borderRadius:
        BorderRadius.circular(
          borderRadius,
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(0.05),

            blurRadius: 10,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }
}