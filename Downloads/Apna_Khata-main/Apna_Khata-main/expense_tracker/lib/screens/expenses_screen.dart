import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/widgets/expense_list_item.dart';

// Enum to define the available filter options
enum FilterType { byDate, byAmount }

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  // State variable to hold the currently active filter
  FilterType _currentFilter = FilterType.byDate;

  Future<bool?> _showDeleteConfirmationDialog() {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this expense? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        // Add a filter button to the AppBar
        actions: [
          PopupMenuButton<FilterType>(
            onSelected: (FilterType result) {
              // Update the state when a new filter is chosen
              setState(() {
                _currentFilter = result;
              });
            },
            icon: const Icon(Icons.filter_list),
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<FilterType>>[
                  const PopupMenuItem<FilterType>(
                    value: FilterType.byDate,
                    child: Text('Most Recent'),
                  ),
                  const PopupMenuItem<FilterType>(
                    value: FilterType.byAmount,
                    child: Text('Highest Price'),
                  ),
                ],
          ),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _firestoreService.getExpensesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No expenses found yet.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          // Create a mutable copy of the expenses list from the snapshot
          final expenses = List<Expense>.from(snapshot.data!);

          // Apply the sorting logic based on the current filter
          if (_currentFilter == FilterType.byAmount) {
            // Sort by amount, from highest to lowest
            expenses.sort((a, b) => b.amount.compareTo(a.amount));
          } else {
            // Default sort: by date, from most recent to oldest
            expenses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Dismissible(
                key: Key(expense.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) => _showDeleteConfirmationDialog(),
                onDismissed: (_) {
                  _firestoreService.deleteExpense(expense.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${expense.item}" deleted.'),
                      backgroundColor: theme.colorScheme.onSurface,
                    ),
                  );
                },
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.delete_forever,
                    color: theme.colorScheme.error,
                  ),
                ),
                child: Padding(
                  // Using the updated ExpenseListItem
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ExpenseListItem(expense: expense, index: index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
