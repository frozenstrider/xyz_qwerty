import 'package:flutter/material.dart';

class SpacingTokens {
  const SpacingTokens._();

  static const double xxxs = 4;
  static const double xxs = 8;
  static const double xs = 12;
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 56;
}

class RadiusTokens {
  const RadiusTokens._();

  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(12));
  static const BorderRadius md = BorderRadius.all(Radius.circular(20));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(28));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(40));
}

class BlurTokens {
  const BlurTokens._();

  static const double ultraThin = 12;
  static const double thin = 16;
  static const double regular = 24;
  static const double thick = 32;
}

class ElevationTokens {
  const ElevationTokens._();

  static const List<BoxShadow> surface = [
    BoxShadow(color: Colors.black26, blurRadius: 24, spreadRadius: -8, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> hover = [
    BoxShadow(color: Colors.black12, blurRadius: 30, spreadRadius: -10, offset: Offset(0, 16)),
  ];
}

class DurationTokens {
  const DurationTokens._();

  static const Duration fast = Duration(milliseconds: 140);
  static const Duration medium = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 420);
}

class CurveTokens {
  const CurveTokens._();

  static const Curve emphasized = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve decelerate = Curves.decelerate;
  static const Curve linear = Curves.linear;
}
