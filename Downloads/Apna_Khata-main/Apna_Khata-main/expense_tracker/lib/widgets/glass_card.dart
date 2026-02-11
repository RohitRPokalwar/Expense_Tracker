import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    // Use the theme's surface color for the card background
    final cardColor = Theme.of(context).colorScheme.surface;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Use a semi-transparent version of the surface color
        color: cardColor.withValues(alpha: 0.8),
        // Use a subtle border based on the text color
        border: Border.all(
          color: Theme.of(
            context,
          ).textTheme.bodyMedium!.color!.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}
