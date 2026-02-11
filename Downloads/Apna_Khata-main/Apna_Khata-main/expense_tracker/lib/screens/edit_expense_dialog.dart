import 'package:flutter/material.dart';

class EditExpenseDialog extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const EditExpenseDialog({super.key, required this.initialData});

  @override
  State<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<EditExpenseDialog> {
  late TextEditingController _itemController;
  late TextEditingController _amountController;
  late String _selectedCategory;

  final _formKey = GlobalKey<FormState>();
  // This is the master list of categories your UI supports.
  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Utilities',
    'Health',
    'Entertainment',
    'Education',
    'Personal Care',
    'Gifts & Donations',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _itemController = TextEditingController(text: widget.initialData['item']);
    _amountController = TextEditingController(
      text: widget.initialData['amount'].toString(),
    );

    // --- THIS IS THE FIX ---
    String initialCategory = widget.initialData['category'];
    // Check if the category from the AI exists in our list.
    if (_categories.contains(initialCategory)) {
      // If it exists, use it.
      _selectedCategory = initialCategory;
    } else {
      // If it DOES NOT exist (e.g., "Food & Dining"), default to "Other".
      // This prevents the app from crashing.
      _selectedCategory = 'Other';
    }
    // --- END OF FIX ---
  }

  @override
  void dispose() {
    _itemController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'item': _itemController.text,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'category': _selectedCategory,
      };
      Navigator.of(context).pop(updatedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Expense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _itemController,
                decoration: const InputDecoration(labelText: 'Item'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter an item'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items:
                    _categories
                        .map(
                          (String category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                onChanged:
                    (newValue) => setState(
                      () => _selectedCategory = newValue ?? _selectedCategory,
                    ),
                validator:
                    (value) =>
                        value == null ? 'Please select a category' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _onSave, child: const Text('Save Changes')),
      ],
    );
  }
}
