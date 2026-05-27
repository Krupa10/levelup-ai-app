import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  final String title;

  final bool isDone;

  final VoidCallback onTap;

  const TaskTile({
    super.key,
    required this.title,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 250),

        margin:
        const EdgeInsets.symmetric(
          vertical: 6,
        ),

        padding:
        const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: isDone
              ? Colors.green.withOpacity(0.08)
              : Theme.of(context).cardColor,

          borderRadius:
          BorderRadius.circular(14),

          border: Border.all(
            color: isDone
                ? Colors.green
                .withOpacity(0.3)
                : Colors.transparent,
          ),
        ),

        child: Row(
          children: [
            AnimatedSwitcher(
              duration:
              const Duration(
                milliseconds: 250,
              ),

              child: Icon(
                isDone
                    ? Icons.check_circle
                    : Icons.circle_outlined,

                key: ValueKey(isDone),

                color: isDone
                    ? Colors.green
                    : Colors.grey,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,

                style: TextStyle(
                  fontSize: 15,

                  fontWeight:
                  FontWeight.w500,

                  decoration: isDone
                      ? TextDecoration
                      .lineThrough
                      : TextDecoration.none,

                  color: isDone
                      ? Colors.grey
                      : Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}