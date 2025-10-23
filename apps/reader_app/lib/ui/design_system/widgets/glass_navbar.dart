import 'package:flutter/material.dart';

import '../tokens.dart';

class GlassNavItem {
  const GlassNavItem(
      {required this.icon, required this.selectedIcon, required this.label});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface;
    final border = theme.colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.lg,
        0,
        SpacingTokens.lg,
        SpacingTokens.lg,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: RadiusTokens.xl,
          border: Border.all(color: border, width: 1.6),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.1),
              offset: const Offset(0, 6),
              blurRadius: 16,
              spreadRadius: -4,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              _NavButton(
                item: items[index],
                selected: index == currentIndex,
                onTap: () => onItemSelected(index),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelMedium ??
        const TextStyle(fontSize: 13, fontWeight: FontWeight.w600);

    final foreground = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.72);
    final background = selected
        ? theme.colorScheme.primary.withOpacity(0.12)
        : Colors.transparent;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiusTokens.xl,
        splashColor: theme.colorScheme.primary.withOpacity(0.15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            vertical: SpacingTokens.sm,
            horizontal: SpacingTokens.sm,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: RadiusTokens.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                color: foreground,
              ),
              const SizedBox(height: SpacingTokens.xxs),
              Text(
                item.label,
                style: labelStyle.copyWith(
                  color: foreground,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
