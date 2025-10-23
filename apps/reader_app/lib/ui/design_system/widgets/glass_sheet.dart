import 'dart:ui';

import 'package:flutter/material.dart';

import '../tokens.dart';

class GlassSheet extends StatelessWidget {
  const GlassSheet({super.key, required this.child, this.title, this.footer, this.padding});

  final Widget child;
  final String? title;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disableMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = disableMotion ? Duration.zero : DurationTokens.medium;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.16);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: BlurTokens.regular, sigmaY: BlurTokens.regular),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, baseColor.withOpacity(0.5), Colors.transparent],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            border: Border.all(color: Colors.white.withOpacity(isDark ? 0.16 : 0.22)),
            boxShadow: ElevationTokens.surface,
          ),
          padding: padding ?? const EdgeInsets.fromLTRB(SpacingTokens.xl, SpacingTokens.lg, SpacingTokens.xl, SpacingTokens.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                  child: Text(title!, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                ),
              Flexible(child: child),
              if (footer != null)
                AnimatedSwitcher(
                  duration: duration,
                  child: Padding(
                    key: ValueKey(footer.hashCode),
                    padding: const EdgeInsets.only(top: SpacingTokens.lg),
                    child: footer,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
