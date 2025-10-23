import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reader_app/domain/models/library_models.dart';
import 'package:reader_app/features/library/providers/library_providers.dart';
import 'package:reader_app/features/title/providers/title_providers.dart';
import 'package:reader_app/ui/design_system/tokens.dart';
import 'package:reader_app/ui/design_system/widgets/glass_sheet.dart';

import '../../shared/widgets/async_value_widget.dart';
import '../../shared/widgets/chapter_tile.dart';
import '../../shared/widgets/series_card.dart';
import '../../shared/widgets/series_cover.dart';

class TitleDetailScreen extends ConsumerWidget {
  const TitleDetailScreen({super.key, required this.titleId});

  final String titleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesValue = ref.watch(seriesProvider(titleId));

    return Scaffold(
      body: SafeArea(
        child: AsyncValueWidget(
          value: seriesValue,
          builder: (series) => _TitleScroll(series: series),
        ),
      ),
    );
  }
}

class _TitleScroll extends ConsumerWidget {
  const _TitleScroll({required this.series});

  final MangaSeries series;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final libraryState = ref.watch(libraryStateProvider);
    final purchaseState = ref.watch(purchasesProvider);

    final isOwned = libraryState.ownedSeries.any((s) => s.id == series.id) ||
        series.chapters.every((chapter) =>
            purchaseState.ownedChapterIds.contains(chapter.id) ||
            !chapter.isLocked);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 360,
          backgroundColor: theme.scaffoldBackgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(series.title,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            background: Padding(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              child: SeriesCover(series: series, aspectRatio: 16 / 9),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                SpacingTokens.lg, SpacingTokens.lg, SpacingTokens.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(series.subtitle,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: SpacingTokens.sm),
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: theme.colorScheme.secondary),
                    const SizedBox(width: 6),
                    Text(series.rating.toStringAsFixed(1),
                        style: theme.textTheme.titleMedium),
                    const SizedBox(width: SpacingTokens.lg),
                    Text(
                        '${series.totalChapters} chapters · ${series.totalVolumes} volumes',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: SpacingTokens.lg),
                Text(series.description, style: theme.textTheme.bodyLarge),
                const SizedBox(height: SpacingTokens.lg),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final genre in series.genres) Chip(label: Text(genre)),
                    for (final tag in series.tags.take(3))
                      Chip(label: Text('#$tag')),
                  ],
                ),
                const SizedBox(height: SpacingTokens.xl),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isOwned
                            ? () => context
                                .go('/reader/${series.chapters.first.id}')
                            : () => _showPurchaseSheet(context, ref, series),
                        icon: Icon(isOwned
                            ? Icons.play_arrow_rounded
                            : Icons.shopping_bag_rounded),
                        label: Text(isOwned
                            ? 'Continue reading'
                            : 'Buy for ${series.isFree ? 'free' : '\$${series.price.toStringAsFixed(2)}'}'),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    IconButton(
                      onPressed: () => _showTranslationPreview(context),
                      tooltip: 'Translation pipeline (coming soon)',
                      icon: const Icon(Icons.translate_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.xl),
                Text('Chapters',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: SpacingTokens.md),
                ...series.chapters.map((chapter) {
                  final owned = !chapter.isLocked ||
                      ref.read(purchasesProvider.notifier).isOwned(chapter.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                    child: ChapterTile(
                      chapter: chapter,
                      isOwned: owned,
                      onTap: () => owned
                          ? context.go('/reader/${chapter.id}')
                          : _showChapterPurchaseSheet(context, ref, chapter),
                      trailing: owned
                          ? const Icon(Icons.play_circle_fill_rounded)
                          : Text('\$${chapter.price.toStringAsFixed(2)}',
                              style: theme.textTheme.labelMedium
                                  ?.copyWith(color: theme.colorScheme.primary)),
                    ),
                  );
                }).toList(),
                const SizedBox(height: SpacingTokens.xl),
                Text('You might also like',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: SpacingTokens.md),
                _RelatedCarousel(seriesId: series.id),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPurchaseSheet(
      BuildContext context, WidgetRef ref, MangaSeries series) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassSheet(
        title: 'Confirm purchase',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buy ${series.title}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: SpacingTokens.sm),
            Text(
                'Includes ${series.totalChapters} chapters and future updates.'),
          ],
        ),
        footer: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  for (final chapter
                      in series.chapters.where((chapter) => chapter.isLocked)) {
                    ref
                        .read(purchasesProvider.notifier)
                        .purchaseChapter(chapter);
                  }
                },
                child:
                    Text('Purchase for \$${series.price.toStringAsFixed(2)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChapterPurchaseSheet(
      BuildContext context, WidgetRef ref, MangaChapter chapter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassSheet(
        title: chapter.title,
        child: const Text(
            'Unlock this chapter to continue. Your purchase will sync across devices.'),
        footer: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Later'),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await ref
                      .read(purchasesProvider.notifier)
                      .purchaseChapter(chapter);
                },
                child: Text('Unlock for \$${chapter.price.toStringAsFixed(2)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTranslationPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const GlassSheet(
        title: 'Translation coming soon',
        child: Text(
          'The Liquid Glass overlay will soon stream translation progress right here. Stay tuned for the pipeline integration.',
        ),
      ),
    );
  }
}

class _RelatedCarousel extends ConsumerWidget {
  const _RelatedCarousel({required this.seriesId});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final related = ref.watch(relatedSeriesProvider(seriesId));
    if (related.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: related.length,
        separatorBuilder: (_, __) => const SizedBox(width: SpacingTokens.md),
        itemBuilder: (context, index) {
          final series = related[index];
          return SizedBox(
            width: 200,
            height: 280,
            child: SeriesCard(
              series: series,
              onTap: () => context.go('/title/${series.id}'),
              compact: true,
            ),
          );
        },
      ),
    );
  }
}
