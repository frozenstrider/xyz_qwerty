import 'package:flutter/material.dart';

import '../tokens.dart';

class GlassSheet extends StatelessWidget {
  const GlassSheet({
    super.key,
    required this.child,
    this.title,
    this.footer,
    this.padding,
  });

  final Widget child;
  final String? title;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final border = theme.colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        border: Border.all(color: border, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.45 : 0.15,
            ),
            offset: const Offset(0, -4),
            blurRadius: 16,
            spreadRadius: -6,
          ),
        ],
      ),
      padding: padding ??
          const EdgeInsets.fromLTRB(
            SpacingTokens.xl,
            SpacingTokens.lg,
            SpacingTokens.xl,
            SpacingTokens.xl,
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.md),
              child: Text(
                title!,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          Flexible(child: child),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.lg),
              child: footer,
            ),
        ],
      ),
    );
  }
}
