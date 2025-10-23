import 'package:flutter/material.dart';
import 'package:reader_app/domain/models/library_models.dart';

class SeriesCover extends StatelessWidget {
  const SeriesCover(
      {super.key,
      required this.series,
      this.aspectRatio = 3 / 4,
      this.borderRadius = const BorderRadius.all(Radius.circular(24)),
      this.showWatermark = true});

  final MangaSeries series;
  final double aspectRatio;
  final BorderRadius borderRadius;
  final bool showWatermark;

  @override
  Widget build(BuildContext context) {
    final primary = Color(series.primaryColor);
    final secondary = Color(series.secondaryColor);
    final overlay = primary.withOpacity(0.35);

    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primary, secondary],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -40,
                right: -20,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: overlay,
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -20,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),
                    color: overlay.withOpacity(0.6),
                  ),
                ),
              ),
              if (showWatermark)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      series.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.86),
                            letterSpacing: 0.8,
                            height: 1.1,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
