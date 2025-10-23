import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/library_models.dart';
import '../../library/providers/library_providers.dart';
import '../../shared/widgets/async_value_widget.dart';
import '../../shared/widgets/series_card.dart';
import '../../shared/widgets/series_cover.dart';
import '../../../ui/design_system/tokens.dart';
import '../../../ui/design_system/widgets/glass_card.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(homeFeedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: AsyncValueWidget(
        value: feed,
        builder: (data) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                SpacingTokens.lg, SpacingTokens.lg, SpacingTokens.xxl),
            children: [
              _PromoHero(featured: data.featured),
              const SizedBox(height: SpacingTokens.xl),
              _DiscoverShelf(title: 'New releases', series: data.newReleases),
              const SizedBox(height: SpacingTokens.xl),
              _DiscoverShelf(title: 'Top paid', series: data.topRated),
              const SizedBox(height: SpacingTokens.xl),
              _DiscoverShelf(
                title: 'Editors\' picks',
                series: [
                  ...data.featured,
                  ...data.topRated.where((s) => !data.featured.contains(s))
                ].take(6).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PromoHero extends StatelessWidget {
  const _PromoHero({required this.featured});

  final List<MangaSeries> featured;

  @override
  Widget build(BuildContext context) {
    final spotlight = featured.isNotEmpty ? featured.first : null;
    final theme = Theme.of(context);
    return GlassCard(
      borderRadius: RadiusTokens.xl,
      padding: const EdgeInsets.all(SpacingTokens.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This week\'s feature', style: theme.textTheme.labelLarge),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  spotlight?.title ?? 'Marketplace spotlight',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  spotlight?.subtitle ??
                      'Handpicked stories you can jump into right now.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8)),
                ),
                const SizedBox(height: SpacingTokens.md),
                Wrap(
                  spacing: SpacingTokens.sm,
                  children: [
                    ElevatedButton.icon(
                      onPressed: spotlight == null
                          ? null
                          : () => context.go('/title/${spotlight.id}'),
                      icon: const Icon(Icons.auto_stories_rounded),
                      label: const Text('Explore catalog'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go('/purchases'),
                      child: const Text('View offers'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (spotlight != null) ...[
            const SizedBox(width: SpacingTokens.xl),
            SizedBox(
              width: 220,
              child: SeriesCover(
                  series: spotlight, aspectRatio: 3 / 4, showWatermark: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiscoverShelf extends StatelessWidget {
  const _DiscoverShelf({required this.title, required this.series});

  final String title;
  final List<MangaSeries> series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            TextButton(
              onPressed: () => context.go('/search'),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        SizedBox(
          height: 360,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: series.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: SpacingTokens.sm),
            itemBuilder: (context, index) {
              final item = series[index];
              return SizedBox(
                width: 240,
                child: SeriesCard(
                  series: item,
                  onTap: () => context.go('/title/${item.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
