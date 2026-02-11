import 'package:flutter/material.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/widgets/custom_card.dart';

class ReviewExpensesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> foundExpenses;

  const ReviewExpensesScreen({super.key, required this.foundExpenses});

  @override
  State<ReviewExpensesScreen> createState() => _ReviewExpensesScreenState();
}

class _ReviewExpensesScreenState extends State<ReviewExpensesScreen> {
  late List<bool> _selected;
  final _firestoreService = FirestoreService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selected = List<bool>.filled(widget.foundExpenses.length, true);
  }

  Future<void> _importSelectedExpenses() async {
    setState(() => _isSaving = true);
    int importCount = 0;

    for (int i = 0; i < widget.foundExpenses.length; i++) {
      if (_selected[i]) {
        final e = widget.foundExpenses[i];
        await _firestoreService.addExpense(
          e['item'],
          e['amount'],
          e['category'],
        );
        importCount++;
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully imported $importCount expenses!'),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = _selected.where((x) => x).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Review & Import')),
      body:
          widget.foundExpenses.isEmpty
              ? Center(
                child: Text(
                  'No debit transactions were found in the PDF.',
                  style: theme.textTheme.bodyLarge,
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                itemCount: widget.foundExpenses.length,
                itemBuilder: (context, index) {
                  final e = widget.foundExpenses[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: CustomCard(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CheckboxListTile(
                        title: Text(
                          e['item'],
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          e['category'],
                          style: theme.textTheme.bodyMedium,
                        ),
                        secondary: Text(
                          '₹${e['amount'].toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        value: _selected[index],
                        onChanged:
                            (v) =>
                                setState(() => _selected[index] = v ?? false),
                        activeColor: theme.colorScheme.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton:
          _isSaving
              ? FloatingActionButton(
                onPressed: null,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
              : FloatingActionButton.extended(
                onPressed: selectedCount > 0 ? _importSelectedExpenses : null,
                label: Text('Import ($selectedCount)'),
                icon: const Icon(Icons.download_done),
                backgroundColor:
                    selectedCount > 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
              ),
    );
  }
}
