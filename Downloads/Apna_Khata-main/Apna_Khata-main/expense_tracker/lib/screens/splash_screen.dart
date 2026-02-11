import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:expense_tracker/screens/auth_gate.dart';
import 'package:expense_tracker/widgets/fade_page_route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    // Safety net: navigate after 3 seconds even if the animation doesn't report loaded.
    Future.delayed(const Duration(seconds: 3), _goNextSafely);
  }

  void _goNextSafely() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(
      context,
    ).pushReplacement(FadePageRoute(page: const AuthGate()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final shadows = Theme.of(context).extension<AppShadows>()!;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        // Soft gradient backdrop similar to the app’s overall look
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEFF7F4), Color(0xFFF7F9F9)],
          ),
        ),
        child: Stack(
          children: [
            // Center Lottie animation card
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: tokens.cardBackground,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                  ),
                  boxShadow: shadows.cardShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Lottie.asset(
                    'assets/add-expense.json',
                    controller: _controller,
                    fit: BoxFit.cover,
                    repeat: false,
                    onLoaded: (composition) {
                      _controller.duration = composition.duration;
                      try {
                        _controller.forward().whenComplete(_goNextSafely);
                      } catch (_) {
                        _goNextSafely();
                      }
                    },
                  ),
                ),
              ),
            ),
            // App title and tagline at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 48,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.primaryAccent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: shadows.cardShadow,
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.06,
                        ),
                      ),
                    ),
                    child: Text(
                      'Expense Manager',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track smarter. Spend better.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
