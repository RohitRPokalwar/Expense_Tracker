import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/widgets/custom_card.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onDismissed;
  final int index;

  const ExpenseListItem({
    super.key,
    required this.expense,
    this.onDismissed,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat.yMMMd().format(expense.timestamp.toDate());

    // Staggered micro-interaction
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.onSurface,
            ),
            child: Icon(Icons.shopping_bag, color: theme.colorScheme.primary),
          ),
          title: Text(
            expense.item,
            style: theme.textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${expense.category} • $date',
            style: theme.textTheme.bodyMedium,
          ),
          trailing: Text(
            '₹${expense.amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
