import 'dart:collection';
import 'dart:math' as math;

class Ripple {
  const Ripple({
    required this.x,
    required this.y,
    required this.birthT,
    required this.amplitude,
    required this.frequency,
    required this.decay,
  });

  final double x;
  final double y;
  final double birthT;
  final double amplitude;
  final double frequency;
  final double decay;
}

class Snapshot {
  const Snapshot({required this.ripples, required this.activePointers});

  final List<Ripple> ripples;
  final int activePointers;
}

class _PointerState {
  _PointerState({
    required this.lastSpawnT,
    required this.lastSpawnX,
    required this.lastSpawnY,
  });

  double lastSpawnT;
  double lastSpawnX;
  double lastSpawnY;
}

class _EngineConfig {
  _EngineConfig({required int maxRipples, required double maxAgeSeconds})
      : maxRipples = maxRipples < 1 ? 1 : maxRipples,
        maxAgeSeconds = maxAgeSeconds < 0.1 ? 0.1 : maxAgeSeconds;

  final int maxRipples;
  final double maxAgeSeconds;
  final double baseAmplitude = 0.25;
  final double baseFrequency = 18.0;
  final double baseDecay = 1.5;
  final double fastCadenceSeconds = 0.15;
  final double slowCadenceSeconds = 0.9;
  final double fastSpeed = 4.0;
  final double minSpawnIntervalS = 0.06;
  final double minSpawnDistance = 0.04;
}

class CurveEngine {
  CurveEngine({required int maxRipples, required double maxAgeSeconds})
      : _cfg = _EngineConfig(
          maxRipples: maxRipples,
          maxAgeSeconds: maxAgeSeconds,
        );

  final _EngineConfig _cfg;
  final Queue<Ripple> _ripples = Queue<Ripple>();
  final Map<int, _PointerState> _pointers = {};
  double? _lastSpawnT;

  Snapshot onPointer({
    required int pointerId,
    required double x,
    required double y,
    required double vx,
    required double vy,
    required double tSeconds,
  }) {
    _prune(tSeconds);

    final prev = _pointers[pointerId];
    final bool shouldSpawn;
    final double? cadence;

    if (prev == null) {
      shouldSpawn = true;
      cadence = _lastSpawnT == null
          ? null
          : math.max(0.0, tSeconds - _lastSpawnT!);
    } else {
      final dt = math.max(0.0, tSeconds - prev.lastSpawnT);
      final dx = x - prev.lastSpawnX;
      final dy = y - prev.lastSpawnY;
      final dist = math.sqrt(dx * dx + dy * dy);
      shouldSpawn =
          dt >= _cfg.minSpawnIntervalS || dist >= _cfg.minSpawnDistance;
      cadence = dt;
    }

    final speed = math.sqrt(vx * vx + vy * vy);
    final speedT = (speed / _cfg.fastSpeed).clamp(0.0, 1.0).toDouble();

    _pointers[pointerId] = _PointerState(
      lastSpawnT: prev == null || shouldSpawn ? tSeconds : prev.lastSpawnT,
      lastSpawnX: prev == null || shouldSpawn ? x : prev.lastSpawnX,
      lastSpawnY: prev == null || shouldSpawn ? y : prev.lastSpawnY,
    );

    if (shouldSpawn) {
      final (amp, freq, decay) = _deriveParams(cadence, speedT);
      while (_ripples.length >= _cfg.maxRipples) {
        _ripples.removeFirst();
      }
      _ripples.add(Ripple(
        x: _clamp01(x),
        y: _clamp01(y),
        birthT: tSeconds,
        amplitude: amp,
        frequency: freq,
        decay: decay,
      ));
      _lastSpawnT = tSeconds;
    }

    return _snapshot();
  }

  Snapshot onPointerUp({required int pointerId, required double tSeconds}) {
    _prune(tSeconds);
    _pointers.remove(pointerId);
    return _snapshot();
  }

  Snapshot tick(double tSeconds) {
    _prune(tSeconds);
    return _snapshot();
  }

  Snapshot _snapshot() => Snapshot(
        ripples: List<Ripple>.unmodifiable(_ripples),
        activePointers: _pointers.length,
      );

  void _prune(double t) {
    final maxAge = _cfg.maxAgeSeconds;
    _ripples.removeWhere((r) => t - r.birthT > maxAge);
  }

  (double, double, double) _deriveParams(double? cadence, double speedT) {
    final double cadenceT;
    if (cadence == null) {
      cadenceT = 1.0;
    } else {
      final span =
          math.max(1e-3, _cfg.slowCadenceSeconds - _cfg.fastCadenceSeconds);
      cadenceT = ((cadence - _cfg.fastCadenceSeconds) / span)
          .clamp(0.0, 1.0)
          .toDouble();
    }

    final amplitudeCadence =
        _lerp(_cfg.baseAmplitude * 0.6, _cfg.baseAmplitude, cadenceT);
    final frequencyCadence =
        _lerp(_cfg.baseFrequency * 1.4, _cfg.baseFrequency, cadenceT);
    final decayCadence = _lerp(_cfg.baseDecay * 1.3, _cfg.baseDecay, cadenceT);

    final amp = _lerp(amplitudeCadence, amplitudeCadence * 1.8, speedT);
    final freq = _lerp(frequencyCadence, frequencyCadence * 0.7, speedT);
    final decay = _lerp(decayCadence, decayCadence * 0.7, speedT);
    return (amp, freq, decay);
  }

  static double _clamp01(double v) =>
      v.isNaN ? 0.5 : v.clamp(0.0, 1.0).toDouble();

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
