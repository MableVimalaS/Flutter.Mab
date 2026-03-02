import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/stat_chip.dart';
import '../../../time_market/presentation/widgets/level_badge.dart';
import '../../../time_market/presentation/widgets/time_receipt.dart';
import '../../../time_market/presentation/widgets/trade_suggestion.dart';
import '../../../time_market/utils/trade_calculator.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<DashboardBloc>().add(const LoadDashboard());
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Dashboard',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your weekly time report',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),

              // --- Quick Stats ---
              Row(
                children: [
                  Expanded(
                    child: StatChip(
                      label: 'Streak',
                      value: '${state.streakDays}d',
                      icon: Icons.local_fire_department_rounded,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatChip(
                      label: 'Today',
                      value: Duration(minutes: state.todaySpentMinutes)
                          .formatted,
                      icon: Icons.today_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatChip(
                      label: 'This Week',
                      value:
                          Duration(minutes: state.weekTotalMinutes).formatted,
                      icon: Icons.date_range_rounded,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Level Badge ---
              Builder(
                builder: (context) {
                  final storage =
                      context.read<StorageService>();
                  return LevelBadge(storageService: storage);
                },
              ),
              const SizedBox(height: 20),

              // --- Daily Receipt ---
              if (state.todayActivities.isNotEmpty) ...[
                Text(
                  "Today's Receipt",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final storage =
                        context.read<StorageService>();
                    return TimeReceipt(
                      activities: state.todayActivities,
                      dailyMoneyBudget: storage.dailyMoneyBudget,
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // --- Trade Suggestions ---
              if (state.todayCategoryMinutes.isNotEmpty)
                Builder(
                  builder: (context) {
                    final suggestions =
                        TradeCalculator.generateSuggestions(
                      state.todayCategoryMinutes,
                    );
                    return TradeSuggestionCard(
                        suggestions: suggestions);
                  },
                ),
              if (state.todayCategoryMinutes.isNotEmpty)
                const SizedBox(height: 20),

              // --- Weekly Bar Chart ---
              Text(
                'Daily Time Spent',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: _WeeklyBarChart(data: state.dailyTotals),
                ),
              ),
              const SizedBox(height: 28),

              // --- Category Pie Chart ---
              if (state.weeklyCategoryTotals.isNotEmpty) ...[
                Text(
                  'Time Distribution',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 240,
                    child: _CategoryPieChart(
                      data: state.weeklyCategoryTotals,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // --- Category Breakdown ---
                Text(
                  'Category Breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...state.weeklyCategoryTotals.entries.map((entry) {
                  final cat = DefaultCategories.getById(entry.key);
                  final totalWeek = state.weekTotalMinutes;
                  final pct = totalWeek > 0
                      ? (entry.value / totalWeek * 100).round()
                      : 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CategoryBar(
                      name: cat.name,
                      icon: cat.icon,
                      color: cat.color,
                      duration: Duration(minutes: entry.value),
                      percentage: pct,
                    ),
                  );
                }),
              ],

              if (state.weeklyCategoryTotals.isEmpty)
                GlassCard(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 48,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No data this week yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.data});

  final List<MapEntry<DateTime, int>> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxVal = data.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    final maxY = maxVal > 0 ? (maxVal / 60).ceilToDouble() + 1 : 8;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final mins = data[groupIndex].value;
              return BarTooltipItem(
                Duration(minutes: mins).formatted,
                TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}h',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data[index].key.shortDay,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color:
                theme.colorScheme.onSurface.withValues(alpha: 0.06),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (i) {
          final hours = data[i].value / 60;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: hours,
                color: theme.colorScheme.primary,
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  const _CategoryPieChart({required this.data});

  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (s, v) => s + v);
    if (total == 0) return const SizedBox.shrink();

    final sections = data.entries.map((entry) {
      final cat = DefaultCategories.getById(entry.key);
      final pct = entry.value / total * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: cat.color,
        radius: 50,
        title: pct >= 8 ? '${pct.round()}%' : '',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.entries.map((entry) {
            final cat = DefaultCategories.getById(entry.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: cat.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.name,
    required this.icon,
    required this.color,
    required this.duration,
    required this.percentage,
  });

  final String name;
  final IconData icon;
  final Color color;
  final Duration duration;
  final int percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                duration.formatted,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '$percentage%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
