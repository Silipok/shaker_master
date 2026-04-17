import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:shaker_master/src/feature/shader_lab/logic/curve_engine.dart';

const int kMaxRipples = 8;

class LiquidPainter extends CustomPainter {
  LiquidPainter({
    required this.shader,
    required this.time,
    required this.size,
    required this.snapshot,
  }) : super(repaint: null);

  final FragmentShader shader;
  final double time;
  final Size size;
  final Snapshot snapshot;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final renderSize = canvasSize.isEmpty ? size : canvasSize;

    shader.setFloat(0, renderSize.width);
    shader.setFloat(1, renderSize.height);
    shader.setFloat(2, time);

    final ripples = snapshot.ripples;
    final active = ripples.length > kMaxRipples ? kMaxRipples : ripples.length;
    shader.setFloat(3, active.toDouble());

    const posBase = 4;
    for (var i = 0; i < kMaxRipples; i++) {
      final xSlot = posBase + i * 2;
      final ySlot = xSlot + 1;
      if (i < active) {
        final r = ripples[i];
        shader.setFloat(xSlot, r.x);
        shader.setFloat(ySlot, r.y);
      } else {
        shader.setFloat(xSlot, 0);
        shader.setFloat(ySlot, 0);
      }
    }

    const paramBase = 4 + kMaxRipples * 2;
    for (var i = 0; i < kMaxRipples; i++) {
      final base = paramBase + i * 4;
      if (i < active) {
        final r = ripples[i];
        shader.setFloat(base, r.birthT);
        shader.setFloat(base + 1, r.amplitude);
        shader.setFloat(base + 2, r.frequency);
        shader.setFloat(base + 3, r.decay);
      } else {
        shader.setFloat(base, 0);
        shader.setFloat(base + 1, 0);
        shader.setFloat(base + 2, 0);
        shader.setFloat(base + 3, 0);
      }
    }

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & renderSize, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidPainter oldDelegate) =>
      oldDelegate.time != time || !identical(oldDelegate.snapshot, snapshot);
}
