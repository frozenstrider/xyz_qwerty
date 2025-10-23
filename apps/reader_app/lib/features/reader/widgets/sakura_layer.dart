import 'dart:math';

import 'package:flutter/material.dart';

class SakuraLayer extends StatefulWidget {
  const SakuraLayer({super.key, required this.enabled});

  final bool enabled;

  @override
  State<SakuraLayer> createState() => _SakuraLayerState();
}

class _SakuraLayerState extends State<SakuraLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_Petal> _petals;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 16))
          ..addListener(() => setState(() {}))
          ..repeat();
    _petals = List.generate(18, (index) => _Petal.random(Random(index * 7)));
  }

  @override
  void didUpdateWidget(covariant SakuraLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();
    return IgnorePointer(
      ignoring: true,
      child: CustomPaint(
        painter: _SakuraPainter(_controller.value, _petals),
      ),
    );
  }
}

class _SakuraPainter extends CustomPainter {
  _SakuraPainter(this.progress, this.petals);

  final double progress;
  final List<_Petal> petals;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final petal in petals) {
      final position = petal.position(progress, size);
      paint.color = petal.color;
      final rect = Rect.fromCenter(
          center: position, width: petal.size, height: petal.size * 0.6);
      final path = Path()
        ..addRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(petal.size / 2)))
        ..close();
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(petal.rotation(progress));
      canvas.translate(-position.dx, -position.dy);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SakuraPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Petal {
  _Petal(
      {required this.seed,
      required this.size,
      required this.speed,
      required this.amplitude,
      required this.baseX,
      required this.startOffset});

  final double seed;
  final double size;
  final double speed;
  final double amplitude;
  final double baseX;
  final double startOffset;

  factory _Petal.random(Random random) {
    return _Petal(
      seed: random.nextDouble(),
      size: random.nextDouble() * 26 + 12,
      speed: random.nextDouble() * 0.6 + 0.4,
      amplitude: random.nextDouble() * 40 + 20,
      baseX: random.nextDouble(),
      startOffset: random.nextDouble(),
    );
  }

  Offset position(double progress, Size size) {
    final t = (progress * speed + startOffset) % 1.0;
    final dy = size.height * t;
    final dx = size.width * baseX + sin((t + seed) * pi * 2) * amplitude;
    return Offset(dx, dy);
  }

  double rotation(double progress) => sin((progress + seed) * pi * 2) * 0.6;

  Color get color =>
      Color.lerp(const Color(0xFFFFBDD9), const Color(0xFFFF4DA6), seed)!
          .withOpacity(0.45);
}
