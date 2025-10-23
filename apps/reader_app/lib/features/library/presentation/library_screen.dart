import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reader_app/domain/models/library_models.dart';
import 'package:reader_app/domain/models/local_library_models.dart';
import 'package:reader_app/features/library/providers/library_providers.dart';
import 'package:reader_app/ui/design_system/tokens.dart';
import 'package:reader_app/ui/design_system/widgets/glass_card.dart';

import '../../shared/widgets/chapter_tile.dart';
import '../../shared/widgets/series_card.dart';
import '../../shared/widgets/series_cover.dart';

final libraryViewModeProvider =
    StateProvider<LibraryViewMode>((ref) => LibraryViewMode.grid);

enum LibraryViewMode { grid, list }

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryStateProvider);
    final repository = ref.watch(libraryRepositoryProvider);
    final viewMode = ref.watch(libraryViewModeProvider);
    final localSeries = ref.watch(localSeriesProvider);

    final recentChapters = libraryState.recentChapterIds
        .map((id) => _findChapter(repository.allSeries, id))
        .whereType<MangaChapter>()
        .toList();
    final ownedSeries = libraryState.ownedSeries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            tooltip: 'Import folder',
            icon: const Icon(Icons.folder_open_rounded),
            onPressed: () async {
              final path = await FilePicker.platform
                  .getDirectoryPath(dialogTitle: 'Select manga folder');
              if (path == null) return;
              final controller = ref.read(localSeriesProvider.notifier);
              try {
                final imported = await controller.importDirectory(path);
                if (!context.mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                if (imported == null) {
                  messenger.showSnackBar(const SnackBar(
                      content: Text('No images found in that folder')));
                } else {
                  messenger.showSnackBar(
                      SnackBar(content: Text('Imported ${imported.title}')));
                }
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Import failed: $error')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_for_offline_rounded),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Downloads management coming soon')),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.lg,
            SpacingTokens.lg, SpacingTokens.xl),
        children: [
          if (recentChapters.isNotEmpty) ...[
            Text('Continue reading',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: SpacingTokens.md),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recentChapters.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: SpacingTokens.md),
                itemBuilder: (context, index) {
                  final chapter = recentChapters[index];
                  final series =
                      ownedSeries.firstWhere((s) => s.id == chapter.seriesId);
                  return SizedBox(
                    width: 220,
                    child: GlassCard(
                      onTap: () => context.go('/reader/'),
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: SeriesCover(
                                  series: series,
                                  aspectRatio: 16 / 9,
                                  showWatermark: false)),
                          const SizedBox(height: SpacingTokens.sm),
                          Text(chapter.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Page ',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: SpacingTokens.xl),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My titles',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              SegmentedButton<LibraryViewMode>(
                selected: <LibraryViewMode>{viewMode},
                segments: const [
                  ButtonSegment(
                      value: LibraryViewMode.grid,
                      icon: Icon(Icons.grid_view_rounded)),
                  ButtonSegment(
                      value: LibraryViewMode.list,
                      icon: Icon(Icons.view_agenda_rounded)),
                ],
                onSelectionChanged: (selection) => ref
                    .read(libraryViewModeProvider.notifier)
                    .state = selection.first,
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),
          if (ownedSeries.isEmpty)
            Column(
              children: [
                Icon(Icons.library_add_rounded,
                    size: 48, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: SpacingTokens.md),
                Text('No titles yet',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: SpacingTokens.xs),
                Text('Browse the marketplace to start your collection.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            )
          else if (viewMode == LibraryViewMode.grid)
            _LibraryGrid(ownedSeries: ownedSeries)
          else
            _LibraryList(ownedSeries: ownedSeries),
          if (localSeries.isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.xl),
            Text('Local imports',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: SpacingTokens.md),
            _LocalLibraryGrid(series: localSeries),
          ],
        ],
      ),
    );
  }

  MangaChapter? _findChapter(List<MangaSeries> series, String id) {
    for (final item in series) {
      for (final chapter in item.chapters) {
        if (chapter.id == id) return chapter;
      }
    }
    return null;
  }
}

class _LibraryGrid extends StatelessWidget {
  const _LibraryGrid({required this.ownedSeries});

  final List<MangaSeries> ownedSeries;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ownedSeries.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: SpacingTokens.md,
        crossAxisSpacing: SpacingTokens.md,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        final series = ownedSeries[index];
        return SeriesCard(
          compact: true,
          series: series,
          onTap: () => context.go('/title/'),
          footer: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: series.tags
                .take(2)
                .map((tag) => Chip(label: Text(tag)))
                .toList(),
          ),
        );
      },
    );
  }
}

class _LibraryList extends ConsumerWidget {
  const _LibraryList({required this.ownedSeries});

  final List<MangaSeries> ownedSeries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryStateProvider);
    return Column(
      children: [
        for (final series in ownedSeries) ...[
          GlassCard(
            onTap: () => context.go('/title/'),
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              children: [
                SizedBox(
                    width: 100,
                    child: SeriesCover(
                        series: series,
                        aspectRatio: 3 / 4,
                        showWatermark: false)),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(series.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(' chapters · ',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: SpacingTokens.sm),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/reader/');
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Continue'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          for (final chapter in series.chapters.take(2))
            ChapterTile(
              chapter: chapter,
              isOwned: !chapter.isLocked,
              onTap: () => context.go('/reader/'),
              trailing: IconButton(
                icon: Icon(
                  libraryState.downloadedChapterIds.contains(chapter.id)
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_download_rounded,
                ),
                onPressed: () => ref
                    .read(libraryStateProvider.notifier)
                    .markChapterDownloaded(chapter.id,
                        isDownloaded: !libraryState.downloadedChapterIds
                            .contains(chapter.id)),
              ),
            ),
          const Divider(height: SpacingTokens.xl),
        ],
      ],
    );
  }
}

class _LocalLibraryGrid extends StatelessWidget {
  const _LocalLibraryGrid({required this.series});

  final List<LocalSeries> series;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: series.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: SpacingTokens.md,
        crossAxisSpacing: SpacingTokens.md,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        final local = series[index];
        final stub = local.toSeriesStub();
        final chapter = local.chapters.isNotEmpty ? local.chapters.first : null;
        return SeriesCard(
          compact: true,
          series: stub,
          onTap: chapter == null
              ? null
              : () => context.push('/reader/local', extra: chapter),
          footer: const Text('Imported RAW'),
        );
      },
    );
  }
}
