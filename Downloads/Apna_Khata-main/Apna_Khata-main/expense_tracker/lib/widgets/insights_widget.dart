import 'package:flutter/material.dart';
import 'package:expense_tracker/services/ai_service.dart';
import 'package:expense_tracker/models/expense_model.dart';

class InsightsWidget extends StatefulWidget {
  final List<Expense> expenses;
  final double income;

  const InsightsWidget({
    super.key,
    required this.expenses,
    required this.income,
  });

  @override
  State<InsightsWidget> createState() => _InsightsWidgetState();
}

class _InsightsWidgetState extends State<InsightsWidget> {
  final AiService _aiService = AiService();
  static bool _hasShownAppreciation = false;
  bool _isLoading = true;
  Map<String, dynamic>? _insights;

  @override
  void initState() {
    super.initState();
    _fetchInsights();
  }

  @override
  void didUpdateWidget(covariant InsightsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expenses != widget.expenses ||
        oldWidget.income != widget.income) {
      _fetchInsights();
    }
  }

  Future<void> _fetchInsights() async {
    if (widget.income <= 0 || widget.expenses.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    final data = await _aiService.getFinancialInsights(
      widget.expenses,
      widget.income,
    );
    if (mounted) {
      setState(() {
        _insights = data;
        _isLoading = false;
      });

      // Show Appreciation Popup if Within Budget
      if (!_hasShownAppreciation &&
          data != null &&
          data['budget_status'] == 'within_budget') {
        _hasShownAppreciation = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAppreciationPopup();
        });
      }
    }
  }

  void _showAppreciationPopup() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 30),
                SizedBox(width: 10),
                Text("Excellent Job! 🎉"),
              ],
            ),
            content: const Text(
              "You are staying within your budget! 🟢\n\nYour financial discipline is impressive. Keep it up to achieve your savings goals!",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Thank You!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_insights == null) return const SizedBox.shrink();

    final score = _insights!['health_score'];
    final alerts = List<String>.from(_insights!['alerts'] ?? []);
    final suggestions = List<String>.from(_insights!['suggestions'] ?? []);

    Color scoreColor = Colors.green;
    if (score < 50) {
      scoreColor = Colors.red;
    } else if (score < 80) {
      scoreColor = Colors.orange;
    }

    return Column(
      children: [
        // 1. Budget Monitoring Card
        if (alerts.isNotEmpty)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Budget Monitoring",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: scoreColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: scoreColor, width: 2),
                        ),
                        child: Text(
                          "$score",
                          style: TextStyle(
                            color: scoreColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...alerts.map((alert) => _buildAlertItem(alert)),
                ],
              ),
            ),
          ),

        // 2. Bachat Guru Card
        if (suggestions.isNotEmpty)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.self_improvement,
                        color: Colors.blue,
                        size: 28,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Bachat Guru",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...suggestions.map((tip) => _buildSuggestionItem(tip)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAlertItem(String alert) {
    bool isPositive = alert.contains("🟢");
    bool isNegative = alert.contains("🔴");
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPositive
                ? Icons.check_circle
                : (isNegative ? Icons.warning_rounded : Icons.info),
            size: 20,
            color:
                isPositive
                    ? Colors.green
                    : (isNegative ? Colors.orange : Colors.red),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alert,
              style: const TextStyle(fontSize: 14, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, size: 20, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 14,
                height: 1.3,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
