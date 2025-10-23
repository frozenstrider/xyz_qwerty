import 'dart:ui';

import 'package:flutter/material.dart';

import '../tokens.dart';

class GlassNavItem {
  const GlassNavItem({required this.icon, required this.selectedIcon, required this.label});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class GlassNavBar extends StatelessWidget {
  const GlassNavBar({super.key, required this.items, required this.currentIndex, required this.onItemSelected});

  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disableMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.14);

    return Padding(
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0, SpacingTokens.lg, SpacingTokens.lg),
      child: ClipRRect(
        borderRadius: RadiusTokens.xl,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: BlurTokens.thin, sigmaY: BlurTokens.thin),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor,
                  baseColor.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
              borderRadius: RadiusTokens.xl,
              border: Border.all(color: Colors.white.withOpacity(isDark ? 0.12 : 0.18)),
              boxShadow: ElevationTokens.surface,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(isDark ? 0.06 : 0.12),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (int index = 0; index < items.length; index++)
                      _GlassNavButton(
                        item: items[index],
                        selected: index == currentIndex,
                        index: index,
                        onTap: () => onItemSelected(index),
                        disableMotion: disableMotion,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavButton extends StatelessWidget {
  const _GlassNavButton({required this.item, required this.selected, required this.index, required this.onTap, required this.disableMotion});

  final GlassNavItem item;
  final bool selected;
  final int index;
  final VoidCallback onTap;
  final bool disableMotion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = disableMotion ? Duration.zero : DurationTokens.medium;
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onSurfaceVariant;
    final labelBase = theme.textTheme.labelMedium ?? const TextStyle(fontSize: 12);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiusTokens.xl,
        child: AnimatedContainer(
          duration: duration,
          curve: CurveTokens.emphasized,
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm, horizontal: SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: RadiusTokens.xl,
            color: selected ? selectedColor.withOpacity(0.18) : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: duration,
                scale: selected ? 1.05 : 1.0,
                curve: CurveTokens.emphasized,
                child: Icon(selected ? item.selectedIcon : item.icon, color: selected ? selectedColor : unselectedColor),
              ),
              const SizedBox(height: SpacingTokens.xxs),
              AnimatedDefaultTextStyle(
                duration: duration,
                curve: CurveTokens.emphasized,
                style: labelBase.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? selectedColor : unselectedColor,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
