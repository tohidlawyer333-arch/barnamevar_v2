import 'dart:math' as math;

import 'package:flutter/material.dart';

double _linear(int channel) {
  final value = channel / 255;
  return value <= 0.04045
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
}

double luminance(Color color) =>
    0.2126 * _linear(color.red) +
    0.7152 * _linear(color.green) +
    0.0722 * _linear(color.blue);

double contrastRatio(Color first, Color second) {
  final firstLuminance = luminance(first);
  final secondLuminance = luminance(second);
  final lighter = math.max(firstLuminance, secondLuminance);
  final darker = math.min(firstLuminance, secondLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}

Color readableOn(Color background) =>
    contrastRatio(background, Colors.white) >= 4.5
        ? Colors.white
        : Colors.black;
