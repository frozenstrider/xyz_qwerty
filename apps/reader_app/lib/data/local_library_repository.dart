import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:reader_app/domain/models/local_library_models.dart';

class LocalLibraryRepository {
  static const List<String> _supportedExts = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.avif'
  ];

  Future<LocalSeries?> importFolder(String directoryPath) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) {
      return null;
    }

    final entries = await dir
        .list(recursive: true, followLinks: false)
        .where((entity) => entity is File && _isSupported(entity.path))
        .cast<File>()
        .toList();

    if (entries.isEmpty) {
      return null;
    }

    entries
        .sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    final chapter = LocalChapter(
      name: p.basename(directoryPath),
      pages: entries.map((file) => file.path).toList(),
    );

    return LocalSeries(
      id: directoryPath,
      title: p.basename(directoryPath),
      chapters: [chapter],
    );
  }

  bool _isSupported(String path) {
    final lower = path.toLowerCase();
    return _supportedExts.any(lower.endsWith);
  }
}
