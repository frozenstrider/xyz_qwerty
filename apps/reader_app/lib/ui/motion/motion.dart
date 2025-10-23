import 'package:flutter/physics.dart';

import '../design_system/tokens.dart';

class Motion {
  const Motion._();

  static SpringDescription get spring => const SpringDescription(mass: 1, stiffness: 240, damping: 24);
  static SpringDescription get softSpring => const SpringDescription(mass: 1, stiffness: 160, damping: 18);

  static Duration get quick => DurationTokens.fast;
  static Duration get standard => DurationTokens.medium;
  static Duration get leisurely => DurationTokens.slow;
}
