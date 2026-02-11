import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  late DateTime _selectedDate;

  final _formKey = GlobalKey<FormState>();
  // Synchronized with backend app.py
  final List<String> _categories = [
    'Food & Dining',
    'Grocery',
    'Housing & Rent',
    'Transport',
    'Travel',
    'Shopping & Lifestyle',
    'Health',
    'Personal Care',
    'Education',
    'Investments',
    'Utilities & Bills',
    'Pets',
    'Entertainment',
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

    // Initialize Date
    if (widget.initialData['date'] != null) {
      try {
        // Try parsing YYYY-MM-DD
        _selectedDate = DateTime.parse(widget.initialData['date']);
      } catch (e) {
        // Fallback to now if parse fails
        _selectedDate = DateTime.now();
      }
    } else {
      _selectedDate = DateTime.now();
    }

    String initialCategory = widget.initialData['category'];
    // Check if the category from the AI exists in our list.
    if (_categories.contains(initialCategory)) {
      _selectedCategory = initialCategory;
    } else {
      // Try to match partial (e.g. "Food" -> "Food & Dining")
      final match = _categories.firstWhere(
        (c) => c.startsWith(initialCategory) || initialCategory.startsWith(c),
        orElse: () => 'Other',
      );
      _selectedCategory = match;
    }
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
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(_selectedDate), // Return date only
      };
      Navigator.of(context).pop(updatedData);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
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
              // Date Picker Field
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                ),
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
                            child: Text(
                              category,
                            ), // Allow customization if needed
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
