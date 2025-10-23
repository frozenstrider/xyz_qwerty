import 'dart:ui';

import 'package:flutter/material.dart';

import '../tokens.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.onTap, this.padding, this.blurSigma = BlurTokens.regular, this.borderRadius = RadiusTokens.lg});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color baseColor = isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.14);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor,
        baseColor.withOpacity(0.18),
        Colors.white.withOpacity(isDark ? 0.03 : 0.07),
      ],
      stops: const [0, 0.55, 1],
    );

    final glassDecoration = BoxDecoration(
      gradient: gradient,
      borderRadius: borderRadius,
      border: Border.all(color: Colors.white.withOpacity(isDark ? 0.16 : 0.22)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
          offset: const Offset(0, 18),
          blurRadius: 42,
          spreadRadius: -16,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(isDark ? 0.05 : 0.18),
          offset: const Offset(-6, -6),
          blurRadius: 24,
          spreadRadius: -18,
        ),
      ],
    );

    final highlightDecoration = BoxDecoration(
      borderRadius: borderRadius,
      gradient: RadialGradient(
        center: Alignment.topLeft,
        radius: 1.2,
        colors: [
          Colors.white.withOpacity(isDark ? 0.16 : 0.28),
          Colors.transparent,
        ],
      ),
    );

    final content = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: glassDecoration,
          foregroundDecoration: highlightDecoration,
          padding: padding ?? const EdgeInsets.all(SpacingTokens.md),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
