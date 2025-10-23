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

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: borderRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final ratio = compact ? 1.0 : 3 / 4;
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
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(SpacingTokens.md, SpacingTokens.md, SpacingTokens.md, SpacingTokens.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  series.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (series.subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      series.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
                    ),
                  ),
                const SizedBox(height: SpacingTokens.sm),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: theme.colorScheme.secondary, size: 18),
                    const SizedBox(width: 6),
                    Text(series.rating.toStringAsFixed(1), style: textTheme.labelMedium),
                    const Spacer(),
                    _PriceChip(series: series),
                  ],
                ),
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(SpacingTokens.md, 0, SpacingTokens.md, SpacingTokens.md),
              child: footer!,
            ),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm, vertical: 6),
        child: Text(
          isFree ? 'Included' : '\$${series.price.toStringAsFixed(2)}',
          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
