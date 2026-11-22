import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class AnalogClockWidget extends StatelessWidget {
  final DateTime time;
  final double size;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color secondHandColor;
  final Color dialColor;
  final bool showSeconds;

  const AnalogClockWidget({
    super.key,
    required this.time,
    this.size = 200,
    this.hourHandColor = Colors.white,
    this.minuteHandColor = Colors.white,
    this.secondHandColor = Colors.amberAccent,
    this.dialColor = Colors.transparent,
    this.showSeconds = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _AnalogClockPainter(
          time: time,
          hourHandColor: hourHandColor,
          minuteHandColor: minuteHandColor,
          secondHandColor: secondHandColor,
          showSeconds: showSeconds,
        ),
      ),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  final DateTime time;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color secondHandColor;
  final bool showSeconds;

  _AnalogClockPainter({
    required this.time,
    required this.hourHandColor,
    required this.minuteHandColor,
    required this.secondHandColor,
    required this.showSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final radius = size.width / 2.0;

    // 1. Dial background glow
    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius - 1.0, borderPaint);

    final innerRingPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 6.0, innerRingPaint);

    // 2. Draw 60 Minute & Hour Ticks starting at 12 o'clock (-90 degrees)
    final cardinalTickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final majorTickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final minorTickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      // (i * 6 - 90) aligns i=0 with 12 o'clock (top)
      final angle = (i * 6.0 - 90.0) * math.pi / 180.0;
      final isCardinal = i % 15 == 0; // 12, 3, 6, 9
      final isMajor = i % 5 == 0; // Every hour

      final tickLength = isCardinal ? 13.0 : (isMajor ? 9.0 : 4.5);
      final tickPaint = isCardinal
          ? cardinalTickPaint
          : (isMajor ? majorTickPaint : minorTickPaint);

      final outer = Offset(
        center.dx + (radius - 8.0) * math.cos(angle),
        center.dy + (radius - 8.0) * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - 8.0 - tickLength) * math.cos(angle),
        center.dy + (radius - 8.0 - tickLength) * math.sin(angle),
      );

      canvas.drawLine(inner, outer, tickPaint);
    }

    // 3. Draw Numerals 12, 3, 6, 9
    _drawCardinalNumerals(canvas, center, radius);

    // 4. Exact Hand Angle Calculations
    // Eliminate millisecond jitter for clean discrete ticks aligned with dial marks
    final secondVal = time.second.toDouble();
    final minuteVal = time.minute + (secondVal / 60.0);
    final hourVal = (time.hour % 12) + (minuteVal / 60.0);

    // All angles start at -90 degrees (12 o'clock / top)
    final hourAngle = (hourVal * 30.0 - 90.0) * math.pi / 180.0;
    final minuteAngle = (minuteVal * 6.0 - 90.0) * math.pi / 180.0;
    final secondAngle = (secondVal * 6.0 - 90.0) * math.pi / 180.0;

    // 5. Draw Hour Hand
    final hourLength = radius * 0.56;
    final hourTailLength = radius * 0.12;

    final hourPaint = Paint()
      ..color = hourHandColor
      ..strokeWidth = 4.8
      ..strokeCap = StrokeCap.round;

    final hourStart = Offset(
      center.dx - hourTailLength * math.cos(hourAngle),
      center.dy - hourTailLength * math.sin(hourAngle),
    );
    final hourEnd = Offset(
      center.dx + hourLength * math.cos(hourAngle),
      center.dy + hourLength * math.sin(hourAngle),
    );

    // Hour hand shadow
    final shadowOffset = const Offset(1.5, 2.0);
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      hourStart + shadowOffset,
      hourEnd + shadowOffset,
      shadowPaint,
    );
    canvas.drawLine(hourStart, hourEnd, hourPaint);

    // 6. Draw Minute Hand
    final minuteLength = radius * 0.76;
    final minuteTailLength = radius * 0.14;

    final minutePaint = Paint()
      ..color = minuteHandColor.withValues(alpha: 0.95)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final minuteStart = Offset(
      center.dx - minuteTailLength * math.cos(minuteAngle),
      center.dy - minuteTailLength * math.sin(minuteAngle),
    );
    final minuteEnd = Offset(
      center.dx + minuteLength * math.cos(minuteAngle),
      center.dy + minuteLength * math.sin(minuteAngle),
    );

    final minuteShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      minuteStart + shadowOffset,
      minuteEnd + shadowOffset,
      minuteShadowPaint,
    );
    canvas.drawLine(minuteStart, minuteEnd, minutePaint);

    // 7. Draw Second Hand
    if (showSeconds) {
      final secondLength = radius * 0.84;
      final secondTailLength = radius * 0.20;

      final secondPaint = Paint()
        ..color = secondHandColor
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;

      final secondStart = Offset(
        center.dx - secondTailLength * math.cos(secondAngle),
        center.dy - secondTailLength * math.sin(secondAngle),
      );
      final secondEnd = Offset(
        center.dx + secondLength * math.cos(secondAngle),
        center.dy + secondLength * math.sin(secondAngle),
      );

      // Second hand shadow
      final secondShadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        secondStart + shadowOffset,
        secondEnd + shadowOffset,
        secondShadowPaint,
      );
      canvas.drawLine(secondStart, secondEnd, secondPaint);

      // Second hand counterbalance circle
      final counterBalancePos = Offset(
        center.dx - (secondTailLength * 0.65) * math.cos(secondAngle),
        center.dy - (secondTailLength * 0.65) * math.sin(secondAngle),
      );
      final counterBalancePaint = Paint()
        ..color = secondHandColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(counterBalancePos, 3.2, counterBalancePaint);
    }

    // 8. Center Hub
    final hubOuterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5.5, hubOuterPaint);

    final hubMiddlePaint = Paint()
      ..color = showSeconds ? secondHandColor : const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, hubMiddlePaint);

    final hubPinPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 1.8, hubPinPaint);
  }

  void _drawCardinalNumerals(Canvas canvas, Offset center, double radius) {
    const textStyle = TextStyle(
      color: Colors.white70,
      fontSize: 12.0,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );

    final numerals = [
      (text: '12', angle: -90.0),
      (text: '3', angle: 0.0),
      (text: '6', angle: 90.0),
      (text: '9', angle: 180.0),
    ];

    final numeralRadius = radius - 26.0;

    for (final (:text, :angle) in numerals) {
      final rad = angle * math.pi / 180.0;
      final textSpan = TextSpan(text: text, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final x =
          center.dx + numeralRadius * math.cos(rad) - (textPainter.width / 2.0);
      final y =
          center.dy +
          numeralRadius * math.sin(rad) -
          (textPainter.height / 2.0);

      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _AnalogClockPainter oldDelegate) {
    return oldDelegate.time.second != time.second ||
        oldDelegate.time.minute != time.minute ||
        oldDelegate.time.hour != time.hour;
  }
}
