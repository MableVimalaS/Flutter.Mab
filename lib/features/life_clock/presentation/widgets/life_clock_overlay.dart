import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/glass_card.dart';
import '../bloc/life_clock_bloc.dart';
import 'arm_clock_painter.dart';
import 'life_stat_row.dart';

class LifeClockOverlay extends StatefulWidget {
  const LifeClockOverlay({super.key});

  @override
  State<LifeClockOverlay> createState() => _LifeClockOverlayState();
}

class _LifeClockOverlayState extends State<LifeClockOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Life Clock'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<LifeClockBloc, LifeClockState>(
        builder: (context, state) {
          if (!state.hasBirthYear) {
            return const Center(child: Text('No birth year set'));
          }

          final ringColor = state.lifeFraction < 0.5
              ? Colors.green
              : state.lifeFraction < 0.75
                  ? Colors.orange
                  : theme.colorScheme.error;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Arm Clock
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return SizedBox(
                      width: 260,
                      height: 260,
                      child: CustomPaint(
                        painter: ArmClockPainter(
                          lifeFraction: state.lifeFraction,
                          pulseValue: _pulseController.value,
                          ringColor: ringColor,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'TIME LEFT',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 3,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${state.remainingYears}y ${state.remainingMonths}m',
                                style:
                                    theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: ringColor,
                                ),
                              ),
                              Text(
                                '${state.remainingDays}d '
                                '${state.remainingHours.toString().padLeft(2, '0')}:'
                                '${state.remainingMinutes.toString().padLeft(2, '0')}:'
                                '${state.remainingSeconds.toString().padLeft(2, '0')}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Life progress bar
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Life Progress',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(state.lifeFraction * 100).toStringAsFixed(1)}%',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ringColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: state.lifeFraction,
                          backgroundColor: ringColor.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(ringColor),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Born ${state.birthYear}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          Text(
                            'Est. ${state.birthYear! + (state.adjustedLifeExpectancyDays / 365).round()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Life stats
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Life Breakdown',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LifeStatRow(
                        label: 'Years lived',
                        value:
                            '${state.elapsedDuration.inDays ~/ 365} years',
                        icon: Icons.cake_rounded,
                        color: Colors.purple,
                      ),
                      LifeStatRow(
                        label: 'Days lived',
                        value: '${_formatNumber(state.elapsedDuration.inDays)} days',
                        icon: Icons.calendar_today_rounded,
                        color: Colors.blue,
                      ),
                      LifeStatRow(
                        label: 'Hours lived',
                        value: '${_formatNumber(state.elapsedDuration.inHours)} hrs',
                        icon: Icons.access_time_rounded,
                        color: Colors.teal,
                      ),
                      LifeStatRow(
                        label: 'Remaining days',
                        value:
                            '${_formatNumber(state.remainingDuration.inDays)} days',
                        icon: Icons.hourglass_bottom_rounded,
                        color: ringColor,
                      ),
                      LifeStatRow(
                        label: 'Remaining hours',
                        value:
                            '${_formatNumber(state.remainingDuration.inHours)} hrs',
                        icon: Icons.timer_rounded,
                        color: ringColor,
                      ),
                      if (state.lifeBonusDays > 0)
                        LifeStatRow(
                          label: 'Bonus from coins',
                          value: '+${state.lifeBonusDays} days',
                          icon: Icons.monetization_on_rounded,
                          color: Colors.amber,
                        ),
                      if (state.lifePenaltyMinutes > 0)
                        LifeStatRow(
                          label: 'Lost to bad habits',
                          value:
                              '\u2212${state.lifePenaltyMinutes} min',
                          icon: Icons.heart_broken_rounded,
                          color: Colors.red,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
