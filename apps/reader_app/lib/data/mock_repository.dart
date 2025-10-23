import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

import 'package:reader_app/domain/models/library_models.dart';
import 'package:reader_app/domain/models/reader_models.dart';

class MockLibraryRepository {
  MockLibraryRepository({this.latency = const Duration(milliseconds: 380)}) {
    _seriesIndex = _buildSeries();
    for (final series in _seriesIndex) {
      _seriesMap[series.id] = series;
      for (final chapter in series.chapters) {
        _chapterMap[chapter.id] = chapter;
      }
    }
  }

  final Duration latency;
  late final List<MangaSeries> _seriesIndex;
  final Map<String, MangaSeries> _seriesMap = {};
  final Map<String, MangaChapter> _chapterMap = {};

  Future<MangaHomeFeed> loadHomeFeed() async {
    await Future.delayed(latency);
    final featured = _seriesIndex.where((s) => s.isFeatured).take(3).toList();
    final newReleases = [..._seriesIndex]..sort((a, b) => b.chapters.first.releaseDate.compareTo(a.chapters.first.releaseDate));
    final topRated = [..._seriesIndex]..sort((a, b) => b.rating.compareTo(a.rating));
    return MangaHomeFeed(
      featured: featured,
      newReleases: newReleases.take(6).toList(),
      topRated: topRated.take(6).toList(),
    );
  }

  Future<List<MangaSeries>> search(String query) async {
    await Future.delayed(latency);
    if (query.trim().isEmpty) {
      return _seriesIndex.take(8).toList();
    }
    final lower = query.toLowerCase();
    return _seriesIndex
        .where((series) =>
            series.title.toLowerCase().contains(lower) ||
            series.tags.any((tag) => tag.toLowerCase().contains(lower)) ||
            series.genres.any((genre) => genre.toLowerCase().contains(lower)))
        .toList();
  }

  Future<MangaSeries> fetchSeries(String id) async {
    await Future.delayed(latency);
    final series = _seriesMap[id];
    if (series == null) {
      throw ArgumentError('Series $id not found');
    }
    return series;
  }

  Future<MangaChapter> fetchChapter(String id) async {
    await Future.delayed(latency);
    final chapter = _chapterMap[id];
    if (chapter == null) {
      throw ArgumentError('Chapter $id not found');
    }
    return chapter;
  }

  List<MangaSeries> get allSeries => List.unmodifiable(_seriesIndex);
}

List<MangaSeries> _buildSeries() {
  final seeds = _SeriesSeed.samples;
  return seeds.map((seed) => seed.buildSeries()).toList();
}

class _SeriesSeed {
  const _SeriesSeed({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.author,
    required this.rating,
    required this.genres,
    required this.tags,
    required this.price,
    required this.isPremium,
    required this.totalVolumes,
    required this.totalChapters,
    required this.isFeatured,
    required this.primary,
    required this.secondary,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String author;
  final double rating;
  final List<String> genres;
  final List<String> tags;
  final double price;
  final bool isPremium;
  final int totalVolumes;
  final int totalChapters;
  final bool isFeatured;
  final Color primary;
  final Color secondary;

  MangaSeries buildSeries() {
    final chapters = List.generate(6, (index) => _buildChapter(index));
    return MangaSeries(
      id: id,
      title: title,
      subtitle: subtitle,
      description: description,
      author: author,
      rating: rating,
      genres: genres,
      tags: tags,
      price: price,
      isPremium: isPremium,
      totalVolumes: totalVolumes,
      totalChapters: totalChapters,
      isFeatured: isFeatured,
      primaryColor: primary.value,
      secondaryColor: secondary.value,
      chapters: chapters,
    );
  }

  MangaChapter _buildChapter(int index) {
    final chapterId = '$id-ch${index + 1}';
    final pages = List.generate(12, (pageIndex) {
      final t = pageIndex / 11;
      final primaryShade = Color.lerp(primary, Colors.white, t * 0.3) ?? primary;
      final secondaryShade = Color.lerp(secondary, primary, t * 0.5) ?? secondary;
      return ReaderPage(
        id: '$chapterId-page${pageIndex + 1}',
        assetPath: null,
        previewLabel: 'Pg ${pageIndex + 1}',
        aspectRatio: pageIndex.isEven ? 0.7 : 0.64,
        primaryColor: primaryShade,
        secondaryColor: secondaryShade,
      );
    });

    final release = DateTime.now().subtract(Duration(days: index * 9 + Random(index + primary.value).nextInt(5)));
    final locked = index > 1 && isPremium;
    final purchased = index == 2 && isPremium;

    return MangaChapter(
      id: chapterId,
      seriesId: id,
      title: 'Episode ${index + 1}: ${_chapterTitles[(index + title.length) % _chapterTitles.length]}',
      number: index + 1,
      releaseDate: release,
      price: locked ? (price > 0 ? price / 3 : 0) : 0,
      isLocked: locked && !purchased,
      isPurchased: !locked || purchased,
      isDownloaded: index == 0,
      lastReadPage: index == 0 ? 4 : 0,
      pages: pages,
    );
  }

  static List<_SeriesSeed> get samples => const [
        _SeriesSeed(
          id: 'starlight-courier',
          title: 'Starlight Courier',
          subtitle: 'Midnight deliveries across the cosmos',
          description:
              'Lyra navigates luminous nebulae delivering mysterious packages that could shift the balance of the galaxy. Each delivery unravels a secret about her lost mentor.',
          author: 'Ria Takane',
          rating: 4.8,
          genres: ['Sci-Fi', 'Adventure'],
          tags: ['space', 'found family', 'mystery'],
          price: 5.99,
          isPremium: true,
          totalVolumes: 5,
          totalChapters: 42,
          isFeatured: true,
          primary: Color(0xFF7B61FF),
          secondary: Color(0xFF1F1147),
        ),
        _SeriesSeed(
          id: 'sakura-sketchbook',
          title: 'Sakura Sketchbook',
          subtitle: 'Finding color after winter',
          description:
              'A shy art student returns to her seaside hometown to rekindle a childhood promise. Her sketches begin to blossom into portals revealing the feelings she buried.',
          author: 'Mika Ayane',
          rating: 4.6,
          genres: ['Slice of Life', 'Romance'],
          tags: ['art school', 'small town', 'healing'],
          price: 0,
          isPremium: false,
          totalVolumes: 3,
          totalChapters: 28,
          isFeatured: true,
          primary: Color(0xFFFF7DA6),
          secondary: Color(0xFF5B1B2D),
        ),
        _SeriesSeed(
          id: 'neon-rail',
          title: 'Neon Rail',
          subtitle: 'The city never sleeps—neither do its trains',
          description:
              'An ex-detective boards a ghost train that appears only at 2:13 AM. Each ride reveals fragments of an unsolved case tied to the city’s neon underbelly.',
          author: 'K. Morimoto',
          rating: 4.9,
          genres: ['Thriller', 'Urban Fantasy'],
          tags: ['detective', 'cyberpunk', 'supernatural'],
          price: 6.99,
          isPremium: true,
          totalVolumes: 6,
          totalChapters: 54,
          isFeatured: true,
          primary: Color(0xFF00E1D4),
          secondary: Color(0xFF032026),
        ),
        _SeriesSeed(
          id: 'clockwork-garden',
          title: 'Clockwork Garden',
          subtitle: 'Where time blooms',
          description:
              'An apprentice horologist discovers a hidden greenhouse where every flower controls a moment in time. She must keep them alive to protect her village from looping days.',
          author: 'Saya Hoshino',
          rating: 4.5,
          genres: ['Fantasy', 'Mystery'],
          tags: ['steampunk', 'time travel', 'mentor'],
          price: 3.99,
          isPremium: false,
          totalVolumes: 4,
          totalChapters: 36,
          isFeatured: false,
          primary: Color(0xFF66C18C),
          secondary: Color(0xFF0F2F20),
        ),
        _SeriesSeed(
          id: 'drift-hunters',
          title: 'Drift Hunters',
          subtitle: 'Ghosts of the mountain pass',
          description:
              'Street racers challenge spirits who guard a legendary mountain road. Victories grant a single wish, but failure adds another restless soul to the course.',
          author: 'Ren Kaido',
          rating: 4.7,
          genres: ['Action', 'Supernatural'],
          tags: ['street racing', 'folklore', 'team'],
          price: 4.99,
          isPremium: true,
          totalVolumes: 7,
          totalChapters: 60,
          isFeatured: false,
          primary: Color(0xFFFFA94D),
          secondary: Color(0xFF311602),
        ),
      ];
}

const _chapterTitles = [
  'Nebula Wake',
  'Signal Bloom',
  'Fractured Echo',
  'Gilded Silence',
  'Parallax Waltz',
  'Phantom Apex',
  'Borealis Sweep',
  'Chiaroscuro',
  'Celestial Ledger',
  'Midnight Sonata',
  'Arcadian Knot',
  'Riven Tides',
];



