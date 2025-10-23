import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme.dart' show SurfaceStyle, SurfaceVariant;
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
    final variant = Theme.of(context).extension<SurfaceStyle>()?.variant ?? SurfaceVariant.glass;
    if (variant == SurfaceVariant.comic) {
      return _ComicCard(
        borderRadius: borderRadius,
        padding: padding,
        onTap: onTap,
        child: child,
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color surfaceBlend = Color.alphaBlend(
      scheme.surfaceVariant.withOpacity(isDark ? 0.22 : 0.12),
      scheme.surface.withOpacity(isDark ? 0.72 : 0.48),
    );
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        surfaceBlend.withOpacity(isDark ? 0.92 : 0.82),
        surfaceBlend.withOpacity(isDark ? 0.78 : 0.64),
        surfaceBlend.withOpacity(isDark ? 0.62 : 0.46),
      ],
      stops: const [0, 0.55, 1],
    );

    final glassDecoration = BoxDecoration(
      gradient: gradient,
      borderRadius: borderRadius,
      border: Border.all(color: Colors.white.withOpacity(isDark ? 0.08 : 0.16)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.32 : 0.08),
          offset: const Offset(0, 18),
          blurRadius: 36,
          spreadRadius: -20,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(isDark ? 0.04 : 0.12),
          offset: const Offset(-4, -4),
          blurRadius: 20,
          spreadRadius: -22,
        ),
      ],
    );

    final highlightDecoration = BoxDecoration(
      borderRadius: borderRadius,
      gradient: RadialGradient(
        center: Alignment.topLeft,
        radius: 1.2,
        colors: [
          Colors.white.withOpacity(isDark ? 0.08 : 0.18),
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

class _ComicCard extends StatelessWidget {
  const _ComicCard({
    required this.child,
    required this.borderRadius,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
        border: Border.all(color: Colors.black, width: 1.4),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(SpacingTokens.md),
        child: child,
      ),
    );

    if (onTap == null) {
      return box;
    }

    return InkWell(
      borderRadius: borderRadius,
      onTap: onTap,
      child: box,
    );
  }
}
