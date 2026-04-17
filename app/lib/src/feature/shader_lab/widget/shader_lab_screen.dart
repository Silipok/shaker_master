import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shaker_master/src/feature/shader_lab/logic/curve_engine.dart';
import 'package:shaker_master/src/feature/shader_lab/widget/liquid_painter.dart';

/// Cloth-flavoured shader demo. Each pointer event spawns an analytic ripple
/// in a pure-Dart engine; the snapshot is fed into the fragment shader as 52
/// uniform floats. The shader composites them into a warm satin palette every
/// frame. No textures, no images, no per-tick GPU allocation.
class ShaderLabScreen extends StatefulWidget {
  const ShaderLabScreen({super.key});

  @override
  State<ShaderLabScreen> createState() => _ShaderLabScreenState();
}

class _ShaderLabScreenState extends State<ShaderLabScreen>
    with SingleTickerProviderStateMixin {
  static const _maxRipples = 8;
  static const _maxAgeSeconds = 3.0;

  FragmentProgram? _program;
  late final Ticker _ticker;
  late final CurveEngine _engine;
  double _time = 0.0;
  String? _error;
  Snapshot _snapshot = const Snapshot(ripples: [], activePointers: 0);
  bool _showDebug = false;

  final Map<int, _PointerTrack> _pointerTracks = {};

  @override
  void initState() {
    super.initState();
    _engine = CurveEngine(
      maxRipples: _maxRipples,
      maxAgeSeconds: _maxAgeSeconds,
    );
    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      setState(() {
        _time = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
        _snapshot = _engine.tick(_time);
      });
    });
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await FragmentProgram.fromAsset(
        'shaders/liquid_video_interactive.frag',
      );
      if (!mounted) return;
      setState(() => _program = program);
      _ticker.start();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  (double, double) _normalize(Offset local, Size size) {
    final nx = (local.dx / size.width).clamp(0.0, 1.0).toDouble();
    final ny = (local.dy / size.height).clamp(0.0, 1.0).toDouble();
    return (nx, ny);
  }

  void _handlePointerDown(PointerDownEvent e, Size size) {
    final (nx, ny) = _normalize(e.localPosition, size);
    _pointerTracks[e.pointer] = _PointerTrack(x: nx, y: ny, t: _time);
    final snap = _engine.onPointer(
      pointerId: e.pointer,
      x: nx,
      y: ny,
      vx: 0,
      vy: 0,
      tSeconds: _time,
    );
    setState(() => _snapshot = snap);
  }

  void _handlePointerMove(PointerMoveEvent e, Size size) {
    final (nx, ny) = _normalize(e.localPosition, size);
    final track = _pointerTracks[e.pointer];
    if (track == null) return;
    final dt = (_time - track.t).clamp(1 / 240.0, 0.25);
    final vx = (nx - track.x) / dt;
    final vy = (ny - track.y) / dt;
    track
      ..x = nx
      ..y = ny
      ..t = _time;
    final snap = _engine.onPointer(
      pointerId: e.pointer,
      x: nx,
      y: ny,
      vx: vx,
      vy: vy,
      tSeconds: _time,
    );
    setState(() => _snapshot = snap);
  }

  void _handlePointerUp(PointerEvent e) {
    _pointerTracks.remove(e.pointer);
    final snap = _engine.onPointerUp(pointerId: e.pointer, tSeconds: _time);
    setState(() => _snapshot = snap);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    Widget content;
    if (_error != null) {
      content = ColoredBox(
        color: Colors.red.shade900,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Shader failed to load:\n$_error',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else if (_program == null) {
      content = const ColoredBox(color: Color(0xFF0A0503));
    } else {
      content = Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) => _handlePointerDown(e, screenSize),
        onPointerMove: (e) => _handlePointerMove(e, screenSize),
        onPointerUp: _handlePointerUp,
        onPointerCancel: _handlePointerUp,
        child: CustomPaint(
          size: screenSize,
          painter: LiquidPainter(
            shader: _program!.fragmentShader(),
            time: _time,
            size: screenSize,
            snapshot: _snapshot,
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0A0503),
      appBar: AppBar(
        title: const Text('Shader Lab'),
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _showDebug ? 'Hide debug overlay' : 'Show debug overlay',
            icon: Icon(_showDebug ? Icons.bug_report : Icons.bug_report_outlined),
            onPressed: () => setState(() => _showDebug = !_showDebug),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          content,
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: IgnorePointer(
              child: Text(
                'Satin cloth — tap, drag, swipe',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          if (_showDebug)
            Positioned(
              right: 12,
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
              child: IgnorePointer(
                child: _RippleDebugOverlay(
                  time: _time,
                  snapshot: _snapshot,
                  maxRipples: _maxRipples,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PointerTrack {
  _PointerTrack({required this.x, required this.y, required this.t});

  double x;
  double y;
  double t;
}

class _RippleDebugOverlay extends StatelessWidget {
  const _RippleDebugOverlay({
    required this.time,
    required this.snapshot,
    required this.maxRipples,
  });

  final double time;
  final Snapshot snapshot;
  final int maxRipples;

  @override
  Widget build(BuildContext context) {
    final ripples = snapshot.ripples;

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.92),
          fontSize: 11,
          height: 1.3,
          fontFamily: 'monospace',
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ripples ${ripples.length}/$maxRipples   '
              'pointers ${snapshot.activePointers}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 6),
            if (ripples.isEmpty)
              Text(
                '(tap / swipe surface to spawn)',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              )
            else
              ...List.generate(ripples.length, (i) {
                final r = ripples[i];
                final age = (time - r.birthT).clamp(0.0, double.infinity);
                return Text(_formatRow(i, r, age));
              }),
          ],
        ),
      ),
    );
  }

  String _formatRow(int i, Ripple r, double age) {
    String f2(double v) => v.toStringAsFixed(2);
    String f1(double v) => v.toStringAsFixed(1);
    return '[$i] age=${f2(age)}s amp=${f2(r.amplitude)} '
        'freq=${f1(r.frequency)} decay=${f1(r.decay)} '
        '@(${f2(r.x)},${f2(r.y)})';
  }
}
