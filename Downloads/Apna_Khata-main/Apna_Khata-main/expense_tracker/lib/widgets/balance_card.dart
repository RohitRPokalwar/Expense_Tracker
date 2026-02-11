import 'package:flutter/material.dart';
import 'package:expense_tracker/utils/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final String currency; // e.g., "USD"
  final double amount; // monthly total
  final String subtitle; // e.g., "This month"
  final double? delta; // positive/negative change
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.currency,
    required this.amount,
    required this.subtitle,
    this.delta,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final shadows = Theme.of(context).extension<AppShadows>()!;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: tokens.primaryAccent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: shadows.cardShadow,
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
        child: Stack(
          children: [
            // soft highlight sheen
            Positioned(
              left: 16,
              right: 16,
              top: 10,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currency,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.primaryText.withValues(alpha: 0.8),
                      ),
                    ),
                    Icon(
                      Icons.tune_rounded,
                      color: tokens.primaryText.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: theme.textTheme.displayLarge,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (delta != null)
                      Text(
                        '${delta! >= 0 ? '+' : '-'}₹${delta!.abs().toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              (delta ?? 0) >= 0
                                  ? tokens.accentGreen
                                  : tokens.accentRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (delta != null) const SizedBox(width: 8),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
