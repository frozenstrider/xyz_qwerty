import 'package:flutter/material.dart';
import 'package:reader_app/domain/models/library_models.dart';
import 'package:reader_app/ui/design_system/tokens.dart';
import 'package:reader_app/ui/design_system/widgets/glass_card.dart';

import 'series_cover.dart';

class SeriesCard extends StatelessWidget {
  const SeriesCard({
    super.key,
    required this.series,
    this.onTap,
    this.footer,
    this.compact = false,
    this.badges,
  });

  final MangaSeries series;
  final VoidCallback? onTap;
  final Widget? footer;
  final bool compact;
  final List<Widget>? badges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final borderRadius = BorderRadius.circular(compact ? 22 : 28);
    final EdgeInsetsGeometry contentPadding = compact
        ? const EdgeInsets.fromLTRB(SpacingTokens.sm, SpacingTokens.sm,
            SpacingTokens.sm, SpacingTokens.xs)
        : const EdgeInsets.fromLTRB(SpacingTokens.md, SpacingTokens.md,
            SpacingTokens.md, SpacingTokens.sm);

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: borderRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final ratio = compact ? 2 / 3 : 3 / 4;

              if (!constraints.hasBoundedHeight) {
                return AspectRatio(
                  aspectRatio: ratio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SeriesCover(
                        series: series,
                        aspectRatio: ratio,
                        borderRadius: borderRadius,
                        showWatermark: false,
                      ),
                      _Overlay(badges: badges, borderRadius: borderRadius),
                    ],
                  ),
                );
              }

              final width = constraints.maxWidth;
              final height = width / ratio;

              return SizedBox(
                width: width,
                height: height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SeriesCover(
                      series: series,
                      aspectRatio: ratio,
                      borderRadius: borderRadius,
                      showWatermark: false,
                    ),
                    _Overlay(badges: badges, borderRadius: borderRadius),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  series.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (series.subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      series.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.8)),
                    ),
                  ),
                const SizedBox(height: SpacingTokens.sm),
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: theme.colorScheme.secondary, size: 18),
                    const SizedBox(width: 6),
                    Text(series.rating.toStringAsFixed(1),
                        style: textTheme.labelMedium),
                    const Spacer(),
                    _PriceChip(series: series),
                  ],
                ),
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? SpacingTokens.sm : SpacingTokens.md,
                0,
                compact ? SpacingTokens.sm : SpacingTokens.md,
                compact ? SpacingTokens.sm : SpacingTokens.md,
              ),
              child: footer!,
            ),
        ],
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  const _Overlay({required this.badges, required this.borderRadius});

  final List<Widget>? badges;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.08),
                Colors.black.withOpacity(0.35),
              ],
            ),
          ),
        ),
        if (badges != null && badges!.isNotEmpty)
          Positioned(
            top: SpacingTokens.sm,
            left: SpacingTokens.sm,
            right: SpacingTokens.sm,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: badges!,
            ),
          ),
      ],
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.series});

  final MangaSeries series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFree = series.isFree;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: RadiusTokens.pill,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.72),
            theme.colorScheme.secondary.withOpacity(0.72),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm, vertical: 6),
        child: Text(
          isFree ? 'Included' : '\$${series.price.toStringAsFixed(2)}',
          style: theme.textTheme.labelSmall
              ?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
