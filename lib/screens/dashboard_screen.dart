import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productivity stats')),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          final chartData = provider.completionsByDay(7).entries.toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatsTile(
                    label: 'Total tasks',
                    value: provider.totalTasks.toString(),
                    icon: Icons.list_alt,
                  ),
                  _StatsTile(
                    label: 'Completed today',
                    value: provider.completedToday.toString(),
                    icon: Icons.today,
                  ),
                  _StatsTile(
                    label: 'Completed this week',
                    value: provider.completedThisWeek.toString(),
                    icon: Icons.calendar_view_week,
                  ),
                  _StatsTile(
                    label: 'Completion rate',
                    value:
                        '${(provider.completionRate * 100).toStringAsFixed(0)}%',
                    icon: Icons.check_circle_outline,
                  ),
                  _StatsTile(
                    label: 'Streak',
                    value: '${provider.streak} days',
                    icon: Icons.local_fire_department,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Last 7 days',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 1.6,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= chartData.length) {
                              return const SizedBox.shrink();
                            }
                            final date = chartData[index].key;
                            return Text(_weekdayLabel(date));
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barGroups: [
                      for (int i = 0; i < chartData.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: chartData[i].value.toDouble(),
                              width: 18,
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return labels[date.weekday % 7];
  }
}

class _StatsTile extends StatelessWidget {
  const _StatsTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 320),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
