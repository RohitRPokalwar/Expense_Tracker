import 'package:flutter/material.dart';
import 'package:expense_tracker/utils/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final shadows = Theme.of(context).extension<AppShadows>()!;
    final theme = Theme.of(context);

    // This single, unified widget now handles the styling for all nav buttons.
    Widget navButton({
      required IconData selectedIcon,
      required IconData unselectedIcon,
      required int index,
    }) {
      final bool isSelected = currentIndex == index;

      return GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          // The active button is larger
          height: isSelected ? 68 : 54,
          width: isSelected ? 68 : 54,
          decoration: BoxDecoration(
            // The active button has a yellow background
            color: isSelected ? tokens.primaryAccent : Colors.white,
            shape: BoxShape.circle,
            boxShadow: isSelected ? shadows.floatingShadow : shadows.cardShadow,
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            ),
          ),
          child: Icon(
            // Use a filled icon for the active tab and an outlined one for inactive tabs
            isSelected ? selectedIcon : unselectedIcon,
            color:
                isSelected
                    ? Colors.black87
                    : tokens.iconColor.withValues(alpha: 0.6),
            size:
                isSelected ? 28 : 24, // The active icon is also slightly larger
          ),
        ),
      );
    }

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: tokens.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: shadows.cardShadow,
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
        // The Row is now simplified, calling the same widget for each button
        // and maintaining the visual order from your screenshot.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            navButton(
              selectedIcon: Icons.article,
              unselectedIcon: Icons.article_outlined,
              index: 1, // Expenses
            ),
            navButton(
              selectedIcon: Icons.home,
              unselectedIcon: Icons.home_outlined,
              index: 0, // Home
            ),
            navButton(
              selectedIcon: Icons.bar_chart,
              unselectedIcon: Icons.bar_chart_outlined,
              index: 2, // Analysis/Reports
            ),
            navButton(
              selectedIcon: Icons.person,
              unselectedIcon: Icons.person_outline,
              index: 3, // Profile
            ),
          ],
        ),
      ),
    );
  }
}
