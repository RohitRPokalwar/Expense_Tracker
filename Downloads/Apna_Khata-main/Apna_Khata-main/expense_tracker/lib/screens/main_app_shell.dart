import 'package:flutter/material.dart';
import 'package:animations/animations.dart'; // <-- 1. Import the new package
import 'package:expense_tracker/screens/expenses_screen.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/screens/profile_screen.dart';
import 'package:expense_tracker/screens/reports_screen.dart';
import 'package:expense_tracker/widgets/custom_bottom_nav_bar.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _index = 0;

  final List<Widget> _pages = const [ // Make the list non-const to use runtime keys
    HomeScreen(key: ValueKey('HomeScreen')),
    ExpensesScreen(key: ValueKey('ExpensesScreen')),
    ReportsScreen(key: ValueKey('ReportsScreen')),
    ProfileScreen(key: ValueKey('ProfileScreen')),
  ];

  void _onTap(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The Stack layout is perfect for overlaying the nav bar.
      body: Stack(
        children: [
          // Page content with bottom padding for the nav bar
          Positioned.fill(
            bottom: 100, // Reserve space for the custom nav bar
            child: PageTransitionSwitcher( // <-- 2. Replace IndexedStack
              duration: const Duration(milliseconds: 300), // Control animation speed
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                // Use SharedAxisTransition for the slide effect
                return SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              },
              // The child is the currently selected page.
              child: _pages[_index],
            ),
          ),
          
          // Your custom nav bar remains unchanged
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(currentIndex: _index, onTap: _onTap),
          ),
        ],
      ),
    );
  }
}