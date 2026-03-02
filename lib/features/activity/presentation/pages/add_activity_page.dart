import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../time_market/presentation/widgets/trade_card.dart';
import '../../../time_market/utils/trade_calculator.dart';
import '../../../time_wallet/presentation/bloc/time_wallet_bloc.dart';
import '../../data/models/activity_model.dart';
import '../bloc/activity_bloc.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  String? _selectedCategoryId;
  int _durationMinutes = 30;
  final _noteController = TextEditingController();
  final _expenseController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _expenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Time'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Category Picker ---
            Text(
              'What did you spend time on?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: DefaultCategories.all.map((cat) {
                final selected = _selectedCategoryId == cat.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryId = cat.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? cat.color.withValues(alpha: 0.2)
                          : cat.color.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? cat.color
                            : cat.color.withValues(alpha: 0.15),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon, color: cat.color, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          cat.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: selected
                                ? cat.color
                                : theme.colorScheme.onSurface,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // --- Duration Picker ---
            Text(
              'How long?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDurationSelector(theme),
            const SizedBox(height: 32),

            // --- Quick Duration Chips ---
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [15, 30, 45, 60, 90, 120].map((mins) {
                final hours = mins ~/ 60;
                final rem = mins % 60;
                final label = hours > 0
                    ? (rem > 0 ? '${hours}h ${rem}m' : '${hours}h')
                    : '${mins}m';
                return ActionChip(
                  label: Text(label),
                  onPressed: () =>
                      setState(() => _durationMinutes = mins),
                  backgroundColor: _durationMinutes == mins
                      ? theme.colorScheme.primaryContainer
                      : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // --- Note ---
            Text(
              'Note (optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'e.g., Deep work on project...',
              ),
            ),
            const SizedBox(height: 32),

            // --- Expense ---
            Text(
              'Money spent (optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _expenseController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 40),

            // --- Save Button ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed:
                    _selectedCategoryId != null ? _save : null,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Log Activity'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector(ThemeData theme) {
    final hours = _durationMinutes ~/ 60;
    final mins = _durationMinutes % 60;
    final display = hours > 0
        ? (mins > 0 ? '${hours}h ${mins}m' : '${hours}h')
        : '${mins}m';

    return Column(
      children: [
        Text(
          display,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: theme.colorScheme.primary,
            thumbColor: theme.colorScheme.primary,
            overlayColor:
                theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: _durationMinutes.toDouble(),
            min: 5,
            max: 480,
            divisions: 95,
            label: display,
            onChanged: (v) =>
                setState(() => _durationMinutes = v.round()),
          ),
        ),
      ],
    );
  }

  void _save() {
    if (_selectedCategoryId == null) return;

    final expense =
        double.tryParse(_expenseController.text.trim()) ?? 0.0;

    context.read<ActivityBloc>().add(
          AddActivity(
            categoryId: _selectedCategoryId!,
            durationMinutes: _durationMinutes,
            note: _noteController.text.trim(),
            expenseAmount: expense,
          ),
        );

    context.read<TimeWalletBloc>().add(const RefreshTimeWallet());

    // Build trade result for the card
    final tradeResult = TradeCalculator.evaluateTrade(
      ActivityModel(
        id: '',
        categoryId: _selectedCategoryId!,
        durationMinutes: _durationMinutes,
        date: DateTime.now(),
        note: _noteController.text.trim(),
        expenseAmount: expense,
      ),
    );

    // Show trade card dialog then pop
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TradeCard(tradeResult: tradeResult),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pop();
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
