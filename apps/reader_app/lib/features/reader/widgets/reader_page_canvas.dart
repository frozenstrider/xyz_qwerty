import 'package:flutter/material.dart';
import 'package:reader_app/domain/models/reader_models.dart';
import 'package:reader_app/features/reader/providers/reader_providers.dart';

class ReaderPageCanvas extends StatelessWidget {
  const ReaderPageCanvas(
      {super.key,
      required this.page,
      required this.brightness,
      required this.contrast,
      required this.colorFilter,
      required this.fontScale});

  final ReaderPage page;
  final double brightness;
  final double contrast;
  final ReaderColorFilter colorFilter;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [page.primaryColor, page.secondaryColor],
              ),
            ),
          ),
          _buildBrightnessOverlay(),
          _buildColorOverlay(),
          if (page.previewLabel != null)
            Positioned(
              right: 16,
              bottom: 16,
              child: Text(
                page.previewLabel!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 16 * fontScale,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBrightnessOverlay() {
    if (brightness == 1 && contrast == 1) return const SizedBox.shrink();

    double opacity = 0;
    Color overlay = Colors.transparent;

    if (brightness < 1) {
      overlay = Colors.black;
      opacity += (1 - brightness) * 0.5;
    } else if (brightness > 1) {
      overlay = Colors.white;
      opacity += (brightness - 1) * 0.35;
    }

    if (contrast < 1) {
      overlay = Colors.black;
      opacity += (1 - contrast) * 0.2;
    } else if (contrast > 1) {
      overlay = overlay.withOpacity(opacity + (contrast - 1) * 0.1);
    }

    return DecoratedBox(
      decoration:
          BoxDecoration(color: overlay.withOpacity(opacity.clamp(0, 0.7))),
    );
  }

  Widget _buildColorOverlay() {
    switch (colorFilter) {
      case ReaderColorFilter.neutral:
        return const SizedBox.shrink();
      case ReaderColorFilter.sepia:
        return Container(color: const Color(0xFF704214).withOpacity(0.18));
      case ReaderColorFilter.dusk:
        return Container(color: const Color(0xFF1C1B33).withOpacity(0.22));
      case ReaderColorFilter.midnight:
        return Container(color: Colors.black.withOpacity(0.35));
    }
  }
}
