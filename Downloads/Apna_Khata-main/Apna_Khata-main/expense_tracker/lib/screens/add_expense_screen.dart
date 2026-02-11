import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/screens/edit_expense_dialog.dart';
import 'package:expense_tracker/services/ai_service.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/widgets/custom_card.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? initialText;
  final Map<String, dynamic>? initialData;

  const AddExpenseScreen({super.key, this.initialText, this.initialData});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _textController = TextEditingController();
  final _aiService = AiService();
  final _firestoreService = FirestoreService();

  bool _isProcessing = false;
  Map<String, dynamic>? _processedData;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      setState(() => _processedData = widget.initialData);
    } else if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _textController.text = widget.initialText!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _processAndAnalyzeExpense();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _processAndAnalyzeExpense() async {
    if (_textController.text.isEmpty) return;
    setState(() {
      _isProcessing = true;
      _processedData = null;
      _error = null;
    });

    final inputText = _textController.text;
    Map<String, dynamic>? result;
    if (inputText.length > 80) {
      result = await _aiService.analyzeReceiptImage(inputText);
    } else {
      result = await _aiService.processExpenseText(inputText);
    }

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _processedData = result;
      _error =
          result == null
              ? 'Could not process the expense. Please try again or check the server.'
              : null;
    });
  }

  Future<void> _showEditDialog() async {
    if (_processedData == null) return;
    final updatedData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditExpenseDialog(initialData: _processedData!),
    );
    if (updatedData != null) {
      setState(() => _processedData = updatedData);
    }
  }

  Future<void> _saveConfirmedExpense() async {
    if (_processedData == null) return;
    setState(() => _isProcessing = true);

    DateTime? expenseDate;
    if (_processedData!['date'] != null) {
      try {
        expenseDate = DateTime.parse(_processedData!['date']);
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }
    }

    await _firestoreService.addExpense(
      _processedData!['item'],
      _processedData!['amount'],
      _processedData!['category'],
      date: expenseDate,
    );
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Expense saved successfully!'),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showTextInput = widget.initialData == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          showTextInput ? 'Add Expense with AI' : 'Confirm Scanned Expense',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showTextInput) ...[
              Text(
                'Describe your expense or paste receipt text:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              CustomCard(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  minLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'e.g., "Bought a school bag for 500"',
                  ),
                  onSubmitted: (_) => _processAndAnalyzeExpense(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processAndAnalyzeExpense,
                  child:
                      _isProcessing && _processedData == null
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Analyze Expense'),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (_processedData != null) ...[
              const SizedBox(height: 16),
              CustomCard(
                elevated: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please Confirm Analysis',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      context,
                      'Item',
                      _processedData!['item'].toString(),
                    ),
                    _buildResultRow(
                      context,
                      'Amount',
                      '₹${_processedData!['amount']}',
                    ),
                    _buildResultRow(
                      context,
                      'Category',
                      _processedData!['category'].toString(),
                    ),
                    _buildResultRow(
                      context,
                      'Date',
                      _formatDate(_processedData!['date']),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            onPressed: _showEditDialog,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            label: const Text('Confirm & Save'),
                            onPressed:
                                _isProcessing ? null : _saveConfirmedExpense,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$title:', style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Today';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
