import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reader_app/features/library/providers/library_providers.dart';
import 'package:reader_app/features/search/providers/search_provider.dart';
import 'package:reader_app/ui/design_system/tokens.dart';

import '../../shared/widgets/series_card.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchControllerProvider);
    final searchController = ref.read(searchControllerProvider.notifier);
    final repository = ref.watch(libraryRepositoryProvider);
    final allGenres = {
      for (final series in repository.allSeries) ...series.genres,
    }.toList()
      ..sort();
    final allTags = {
      for (final series in repository.allSeries) ...series.tags,
    }.toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0, SpacingTokens.lg, SpacingTokens.md),
            child: TextField(
              onChanged: searchController.setQuery,
              decoration: InputDecoration(
                hintText: 'Search titles, genres, or tags',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                border: OutlineInputBorder(borderRadius: RadiusTokens.lg, borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.lg, SpacingTokens.lg, SpacingTokens.xl),
        children: [
          _FilterSection(
            title: 'Genres',
            options: allGenres,
            selected: searchState.selectedGenres,
            onSelected: searchController.toggleGenre,
          ),
          const SizedBox(height: SpacingTokens.lg),
          _FilterSection(
            title: 'Tags',
            options: allTags,
            selected: searchState.selectedTags,
            onSelected: searchController.toggleTag,
          ),
          const SizedBox(height: SpacingTokens.xl),
          if (searchState.isSearching)
            const Center(child: Padding(padding: EdgeInsets.all(SpacingTokens.xl), child: CircularProgressIndicator.adaptive())),
          if (!searchState.isSearching && searchState.results.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.xl),
              child: Column(
                children: [
                  Icon(Icons.travel_explore_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: SpacingTokens.md),
                  Text('Search the marketplace', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: SpacingTokens.xs),
                  Text('Try "sakura", "city", or "time" to explore curated picks.',
                      textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          for (final series in searchState.results)
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.lg),
              child: SizedBox(height: 360,
                child: SeriesCard(
                  series: series,
                  onTap: () => context.go('/title/'),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: (searchState.selectedGenres.isNotEmpty || searchState.selectedTags.isNotEmpty)
          ? FloatingActionButton.extended(
              onPressed: searchController.clearFilters,
              label: const Text('Clear filters'),
              icon: const Icon(Icons.filter_alt_off_rounded),
            )
          : null,
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.options, required this.selected, required this.onSelected});

  final String title;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: SpacingTokens.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option),
                selected: selected.contains(option),
                onSelected: (_) => onSelected(option),
              ),
          ],
        ),
      ],
    );
  }
}

