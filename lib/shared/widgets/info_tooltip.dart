import 'package:flutter/material.dart';

class InfoTooltip extends StatelessWidget {
  const InfoTooltip({
    required this.message,
    this.iconSize = 16,
    super.key,
  });

  final String message;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showInfo(context),
      child: Icon(
        Icons.info_outline_rounded,
        size: iconSize,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    final theme = Theme.of(context);
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => entry.remove(),
        child: Stack(
          children: [
            Positioned(
              left: (offset.dx - 100).clamp(16.0, MediaQuery.sizeOf(ctx).width - 250),
              top: offset.dy + renderBox.size.height + 8,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 240),
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(entry);

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });
  }
}
