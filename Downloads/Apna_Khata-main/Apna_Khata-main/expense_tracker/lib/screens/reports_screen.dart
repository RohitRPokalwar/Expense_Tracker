import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:expense_tracker/widgets/custom_card.dart';

// Enum to manage the state of the time filter
enum TimeFilter { day, week, month }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  TimeFilter _selectedFilter = TimeFilter.week;

  /// Filters expenses based on the selected time period.
  List<Expense> _filterExpenses(List<Expense> allExpenses, TimeFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case TimeFilter.day:
        return allExpenses
            .where((e) => DateUtils.isSameDay(e.timestamp.toDate(), now))
            .toList();
      case TimeFilter.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return allExpenses
            .where(
              (e) => e.timestamp.toDate().isAfter(
                startOfWeek.subtract(const Duration(days: 1)),
              ),
            )
            .toList();
      case TimeFilter.month:
        return allExpenses
            .where(
              (e) =>
                  e.timestamp.toDate().month == now.month &&
                  e.timestamp.toDate().year == now.year,
            )
            .toList();
    }
  }

  /// Processes filtered data into a format suitable for the bar chart.
  Map<String, double> _processChartData(
    List<Expense> filteredExpenses,
    TimeFilter filter,
  ) {
    final Map<String, double> chartData = {};
    if (filter == TimeFilter.week) {
      for (int i = 0; i < 7; i++) {
        final day = DateTime.now().subtract(Duration(days: 6 - i));
        chartData[DateFormat.E().format(day)] = 0.0;
      }
      for (var e in filteredExpenses) {
        final dayKey = DateFormat.E().format(e.timestamp.toDate());
        if (chartData.containsKey(dayKey)) {
          chartData[dayKey] = chartData[dayKey]! + e.amount;
        }
      }
    } else {
      for (var e in filteredExpenses) {
        chartData[e.category] = (chartData[e.category] ?? 0) + e.amount;
      }
    }
    return chartData;
  }

  /// Processes raw expense data into a map of {Category: TotalAmount}.
  Map<String, double> _processCategoryData(List<Expense> expenses) {
    final Map<String, double> categoryData = {};
    for (var e in expenses) {
      categoryData[e.category] = (categoryData[e.category] ?? 0) + e.amount;
    }
    return categoryData;
  }

  /// Gets the top 4 spending categories from a list of expenses.
  List<MapEntry<String, double>> _getTopCategories(List<Expense> expenses) {
    final categoryData = _processCategoryData(expenses);
    var sortedItems =
        categoryData.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return sortedItems.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Analysis')),
      body: StreamBuilder<List<Expense>>(
        stream: _firestoreService.getExpensesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No expense data to generate reports.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          final allExpenses = snapshot.data!;
          final filteredExpenses = _filterExpenses(
            allExpenses,
            _selectedFilter,
          );

          // --- MODIFIED: Removed avgSpend and highestSpend ---
          final totalSpend = filteredExpenses.fold<double>(
            0,
            (sum, e) => sum + e.amount,
          );

          final chartData = _processChartData(
            filteredExpenses,
            _selectedFilter,
          );
          final topCategories = _getTopCategories(filteredExpenses);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFilterButtons(theme),
              const SizedBox(height: 24),
              _buildMainChartCard(theme, chartData, totalSpend),
              const SizedBox(height: 24),
              // --- MODIFIED: Call the updated summary card builder ---
              _buildSummaryCard(theme, 'Total Spend', totalSpend),
              const SizedBox(height: 24),
              _buildTopCategoriesCard(theme, topCategories, totalSpend),
            ],
          );
        },
      ),
    );
  }

  // --- UI BUILDER WIDGETS ---

  Widget _buildFilterButtons(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            TimeFilter.values.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      filter.name.capitalize(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildMainChartCard(
    ThemeData theme,
    Map<String, double> chartData,
    double total,
  ) {
    final appColors = theme.extension<AppTokens>()!;
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Balance', style: theme.textTheme.bodyMedium),
              Icon(
                Icons.notifications_none_outlined,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(total),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY:
                    (chartData.values.isEmpty
                        ? 0
                        : chartData.values.reduce((a, b) => a > b ? a : b)) *
                    1.3,
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final label = chartData.keys.elementAt(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            label.substring(0, 3),
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(chartData.length, (i) {
                  final entry = chartData.entries.elementAt(i);
                  final color =
                      appColors.chartPalette[i % appColors.chartPalette.length];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: color,
                        width: 20,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }),
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  // --- MODIFIED: This widget is now standalone ---

  Widget _buildTopCategoriesCard(
    ThemeData theme,
    List<MapEntry<String, double>> topCategories,
    double total,
  ) {
    final appColors = theme.extension<AppTokens>()!;
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Categories', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          ...List.generate(topCategories.length, (i) {
            final category = topCategories[i];
            final percentage = total > 0 ? (category.value / total) * 100 : 0;
            final color =
                appColors.chartPalette[i % appColors.chartPalette.length];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.15),
                    ),
                    child: Icon(Icons.shopping_bag_outlined, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(category.key, style: theme.textTheme.bodyLarge),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'en_IN',
                      symbol: '₹',
                      decimalDigits: 0,
                    ).format(category.value),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

_buildSummaryCard(ThemeData theme, String s, double totalSpend) {
  return CustomCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(s, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(
          NumberFormat.currency(
            locale: 'en_IN',
            symbol: '₹',
            decimalDigits: 0,
          ).format(totalSpend),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// Helper to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
