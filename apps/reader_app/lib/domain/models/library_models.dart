import 'reader_models.dart';

class MangaSeries {
  const MangaSeries({
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
    required this.primaryColor,
    required this.secondaryColor,
    required this.chapters,
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
  final int primaryColor;
  final int secondaryColor;
  final List<MangaChapter> chapters;

  bool get isFree => price == 0;
}

class MangaChapter {
  const MangaChapter({
    required this.id,
    required this.seriesId,
    required this.title,
    required this.number,
    required this.releaseDate,
    required this.price,
    required this.isLocked,
    required this.isPurchased,
    required this.isDownloaded,
    required this.lastReadPage,
    required this.pages,
  });

  final String id;
  final String seriesId;
  final String title;
  final int number;
  final DateTime releaseDate;
  final double price;
  final bool isLocked;
  final bool isPurchased;
  final bool isDownloaded;
  final int lastReadPage;
  final List<ReaderPage> pages;

  bool get isOwned => isPurchased || !isLocked;
}

class PurchaseRecord {
  const PurchaseRecord(
      {required this.id,
      required this.itemId,
      required this.purchasedAt,
      required this.price});

  final String id;
  final String itemId;
  final DateTime purchasedAt;
  final double price;
}

class MangaHomeFeed {
  const MangaHomeFeed(
      {required this.featured,
      required this.newReleases,
      required this.topRated});

  final List<MangaSeries> featured;
  final List<MangaSeries> newReleases;
  final List<MangaSeries> topRated;
}
