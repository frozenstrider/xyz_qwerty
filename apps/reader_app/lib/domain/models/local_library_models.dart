import 'package:flutter/material.dart';

import 'package:reader_app/domain/models/library_models.dart';

class LocalSeries {
  LocalSeries({
    required this.id,
    required this.title,
    required this.chapters,
  });

  final String id;
  final String title;
  final List<LocalChapter> chapters;

  MangaSeries toSeriesStub() {
    final colors = _deriveColors(id);
    final firstChapter = chapters.isNotEmpty ? chapters.first : null;
    return MangaSeries(
      id: 'local-$id',
      title: title,
      subtitle: firstChapter != null
          ? '${firstChapter.pages.length} pages'
          : 'Local folder import',
      description: 'Imported from local storage',
      author: 'Local import',
      rating: 0,
      genres: const ['Local'],
      tags: const ['Local RAW'],
      price: 0,
      isPremium: false,
      totalVolumes: 1,
      totalChapters: chapters.length,
      isFeatured: false,
      primaryColor: colors.$1.value,
      secondaryColor: colors.$2.value,
      chapters: const [],
    );
  }

  (Color, Color) _deriveColors(String seed) {
    final base = seed.hashCode;
    final hue = (base.abs() % 360).toDouble();
    final altHue = (hue + 42) % 360;
    final c1 = HSLColor.fromAHSL(1, hue, 0.55, 0.52).toColor();
    final c2 = HSLColor.fromAHSL(1, altHue, 0.58, 0.42).toColor();
    return (c1, c2);
  }
}

class LocalChapter {
  LocalChapter({required this.name, required this.pages});

  final String name;
  final List<String> pages;
}
