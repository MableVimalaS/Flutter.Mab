import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/glass_card.dart';
import '../bloc/life_clock_bloc.dart';
import 'life_clock_overlay.dart';

class LifeClockCard extends StatelessWidget {
  const LifeClockCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<LifeClockBloc, LifeClockState>(
      builder: (context, state) {
        if (state.isLoading) return const SizedBox.shrink();

        if (!state.hasBirthYear) {
          return GlassCard(
            padding: const EdgeInsets.all(20),
            child: InkWell(
              onTap: () => _showBirthDatePicker(context),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.hourglass_full_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Life Clock',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Set your date of birth to see your life countdown',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          );
        }

        // Has birth date — show compact countdown
        final ringColor = state.lifeFraction < 0.5
            ? Colors.green
            : state.lifeFraction < 0.75
                ? Colors.orange
                : theme.colorScheme.error;

        return GestureDetector(
          onTap: () => _showOverlay(context),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.hourglass_full_rounded,
                      color: ringColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Life Clock',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.fullscreen_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.4),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Countdown display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _CountdownUnit(
                      value: state.remainingYears,
                      label: 'YRS',
                      color: ringColor,
                    ),
                    _CountdownUnit(
                      value: state.remainingMonths,
                      label: 'MOS',
                      color: ringColor,
                    ),
                    _CountdownUnit(
                      value: state.remainingDays,
                      label: 'DAYS',
                      color: ringColor,
                    ),
                    _CountdownUnit(
                      value: state.remainingHours,
                      label: 'HRS',
                      color: ringColor,
                    ),
                    _CountdownUnit(
                      value: state.remainingMinutes,
                      label: 'MIN',
                      color: ringColor,
                    ),
                    _CountdownUnit(
                      value: state.remainingSeconds,
                      label: 'SEC',
                      color: ringColor,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Life progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: state.lifeFraction,
                    backgroundColor: ringColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(ringColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(state.lifeFraction * 100).toStringAsFixed(1)}% of estimated life elapsed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBirthDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Select your date of birth',
    );
    if (picked != null && context.mounted) {
      context.read<LifeClockBloc>().add(SetBirthDate(picked));
    }
  }

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LifeClockOverlay(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  const _CountdownUnit({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            letterSpacing: 1,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
