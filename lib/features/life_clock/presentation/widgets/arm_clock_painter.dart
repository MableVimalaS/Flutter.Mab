import 'dart:math' as math;

import 'package:flutter/material.dart';

class ArmClockPainter extends CustomPainter {
  ArmClockPainter({
    required this.lifeFraction,
    required this.pulseValue,
    required this.ringColor,
    required this.backgroundColor,
  });

  final double lifeFraction;
  final double pulseValue;
  final Color ringColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - 28) / 2;
    const strokeWidth = 12.0;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Tick marks (60 like a clock)
    for (var i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * math.pi - math.pi / 2;
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 10.0 : 5.0;
      final tickWidth = isMajor ? 2.0 : 1.0;
      final outerR = radius + strokeWidth / 2 + 4;
      final innerR = outerR - tickLength;

      final opacity = i / 60 <= lifeFraction ? 0.6 : 0.15;
      final tickPaint = Paint()
        ..color = ringColor.withValues(alpha: opacity)
        ..strokeWidth = tickWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(
          center.dx + outerR * math.cos(angle),
          center.dy + outerR * math.sin(angle),
        ),
        Offset(
          center.dx + innerR * math.cos(angle),
          center.dy + innerR * math.sin(angle),
        ),
        tickPaint,
      );
    }

    // Life elapsed arc
    final sweepAngle = 2 * math.pi * lifeFraction;
    final progressPaint = Paint()
      ..color = ringColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Pulsing glow effect
    final glowAlpha = 0.15 + 0.2 * pulseValue;
    final glowWidth = strokeWidth + 10 + 4 * pulseValue;
    final glowPaint = Paint()
      ..color = ringColor.withValues(alpha: glowAlpha)
      ..strokeWidth = glowWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + 4 * pulseValue);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    // Endpoint dot
    if (lifeFraction > 0) {
      final endAngle = -math.pi / 2 + sweepAngle;
      final dotCenter = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      final dotPaint = Paint()
        ..color = ringColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotCenter, strokeWidth / 2 + 2, dotPaint);

      final dotGlowPaint = Paint()
        ..color = ringColor.withValues(alpha: 0.3 + 0.2 * pulseValue)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(dotCenter, strokeWidth / 2 + 6, dotGlowPaint);
    }
  }

  @override
  bool shouldRepaint(ArmClockPainter oldDelegate) =>
      lifeFraction != oldDelegate.lifeFraction ||
      pulseValue != oldDelegate.pulseValue ||
      ringColor != oldDelegate.ringColor;
}
