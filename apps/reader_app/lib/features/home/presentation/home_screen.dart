import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reader_app/domain/models/library_models.dart';
import 'package:reader_app/features/library/providers/library_providers.dart';
import 'package:reader_app/ui/design_system/tokens.dart';
import 'package:reader_app/ui/design_system/widgets/glass_card.dart';

import '../../shared/widgets/async_value_widget.dart';
import '../../shared/widgets/series_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(homeFeedProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AsyncValueWidget(
        value: feed,
        builder: (data) => _HomeScroll(feed: data),
      ),
    );
  }
}

class _HomeScroll extends ConsumerWidget {
  const _HomeScroll({required this.feed});

  final MangaHomeFeed feed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _MarketplaceHero(),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'New Releases',
                  subtitle: 'Fresh chapters curated daily',
                  action: TextButton.icon(
                    onPressed: () => context.go('/search'),
                    icon: const Icon(Icons.shuffle_rounded),
                    label: const Text('Surprise me'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 360,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: feed.newReleases.length,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    separatorBuilder: (_, __) => const SizedBox(width: 20),
                    itemBuilder: (context, index) {
                      final series = feed.newReleases[index];
                      return SizedBox(
                        width: 240,
                        height: 360,
                        child: SeriesCard(
                          series: series,
                          onTap: () => context.go('/title/${series.id}'),
                          compact: false,
                          badges: [
                            _Badge.chip(label: series.rating.toStringAsFixed(1), icon: Icons.star, color: theme.colorScheme.secondary),
                            if (index < 3) _Badge.pill(label: 'NEW'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                _SearchShortcut(onTap: () => context.go('/search')),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'All Manga',
                  subtitle: 'Browse  collection by popularity',
                  action: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.list_alt_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text('Newest First', style: theme.textTheme.labelLarge),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final series = feed.topRated[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    height: 360,
                    child: SeriesCard(
                      series: series,
                      onTap: () => context.go('/title/${series.id}'),
                      badges: [
                        _Badge.chip(label: series.rating.toStringAsFixed(1), icon: Icons.star, color: theme.colorScheme.secondary),
                      ],
                      footer: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final genre in series.genres.take(3))
                            Chip(
                              label: Text(genre),
                              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: feed.topRated.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 48)),
      ],
    );
  }
}

class _MarketplaceHero extends ConsumerWidget {
  const _MarketplaceHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return GlassCard(
      borderRadius: BorderRadius.circular(40),
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 38),
      blurSigma: BlurTokens.thick,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final content = <Widget>[
            Flexible(fit: FlexFit.loose,
              flex: isWide ? 3 : 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: RadiusTokens.pill,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Text('RAW MANGA MARKETPLACE', style: theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Authentic Japanese Manga',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Purchase official releases directly from Japanese publishers. Support creators and enjoy manga in its original form.',
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.92)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/search'),
                    icon: const Icon(Icons.explore_rounded),
                    label: const Text('Explore catalog'),
                  ),
                ],
              ),
            ),
            if (isWide) const SizedBox(width: 32),
            if (isWide)
              Flexible(fit: FlexFit.loose,
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFA8E7), Color(0xFF7D8CFF)],
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 42, offset: const Offset(0, 18)),
                      ],
                    ),
                    child: const Icon(Icons.collections_bookmark_outlined, color: Colors.white, size: 96),
                  ),
                ),
              ),
          ];

          return isWide ? Row(children: content) : Column(children: content);
        },
      ),
    );
  }
}

class _SearchShortcut extends StatelessWidget {
  const _SearchShortcut({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Flexible(fit: FlexFit.loose,
              child: Text(
                'Search manga, author, or genreâ€¦',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: RadiusTokens.pill,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.8),
                    theme.colorScheme.secondary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Filters', style: theme.textTheme.labelMedium?.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle, this.action});

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8))),
          ],
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge._({required this.child});

  factory _Badge.chip({required String label, required IconData icon, required Color color}) {
    return _Badge._(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: RadiusTokens.pill,
          color: color.withOpacity(0.85),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  factory _Badge.pill({required String label}) {
    return _Badge._(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: RadiusTokens.pill,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7EE5), Color(0xFF7A7DFF)],
          ),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}





