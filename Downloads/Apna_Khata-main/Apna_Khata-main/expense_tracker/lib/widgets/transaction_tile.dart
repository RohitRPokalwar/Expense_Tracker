import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/utils/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final Expense expense;
  final int index; // for staggered animation
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.expense,
    required this.index,
    this.onTap,
  });

  String _relativeTime(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat.yMMMd().format(d);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final when = _relativeTime(expense.timestamp.toDate());

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder:
          (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 12),
              child: child,
            ),
          ),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.iconColor.withValues(alpha: 0.08),
            ),
            child: Icon(Icons.shopping_bag, color: tokens.iconColor),
          ),
          title: Text(expense.item, style: theme.textTheme.bodyLarge),
          subtitle: Text(
            '${expense.category} • $when',
            style: theme.textTheme.bodyMedium,
          ),
          trailing: Text(
            '-₹${expense.amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: tokens.accentGreen,
            ),
          ),
        ),
      ),
    );
  }
}
