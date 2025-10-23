import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius = RadiusTokens.lg,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.36)
        : Colors.black.withOpacity(0.12);

    Widget content = Stack(
      fit: StackFit.passthrough,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(0, 8),
                blurRadius: 18,
                spreadRadius: -6,
              ),
            ],
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(SpacingTokens.md),
            child: child,
          ),
        ),
        IgnorePointer(
          child: CustomPaint(
            painter: _PencilStrokePainter(
              borderRadius: borderRadius,
              baseColor: borderColor,
              isDark: isDark,
            ),
          ),
        ),
      ],
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}

class _PencilStrokePainter extends CustomPainter {
  _PencilStrokePainter({
    required this.borderRadius,
    required this.baseColor,
    required this.isDark,
  }) : _random = math.Random(42);

  final BorderRadius borderRadius;
  final Color baseColor;
  final bool isDark;
  final math.Random _random;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    final primaryStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = isDark ? baseColor.withOpacity(0.9) : baseColor;
    canvas.drawRRect(rrect, primaryStroke);

    for (var i = 0; i < 2; i++) {
      final jitter = (_random.nextDouble() * 0.4) - 0.2;
      final opacity = isDark ? 0.25 : 0.4;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 + jitter
        ..color = baseColor.withOpacity(opacity);
      canvas.drawRRect(rrect.deflate(0.3 + i * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PencilStrokePainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.baseColor != baseColor ||
      oldDelegate.isDark != isDark;
}
