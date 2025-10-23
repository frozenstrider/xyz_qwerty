import 'dart:ui';

enum ReaderMode { vertical, single, double }

class ReaderPage {
  const ReaderPage({
    required this.id,
    this.assetPath,
    this.previewLabel,
    required this.aspectRatio,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final String id;
  final String? assetPath;
  final String? previewLabel;
  final double aspectRatio;
  final Color primaryColor;
  final Color secondaryColor;
}
