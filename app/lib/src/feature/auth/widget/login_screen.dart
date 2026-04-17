import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем реальный размер экрана
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF030D08),
      body: Stack(
        fit: StackFit.expand,
        children: [
          LiquidVideoReplacement(screenSize: screenSize),
          const SafeArea(
            child: Column(
              children: [],
            ),
          ),
        ],
      ),
    );
  }
}

class LiquidVideoReplacement extends StatefulWidget {
  final Size screenSize;

  const LiquidVideoReplacement({super.key, required this.screenSize});

  @override
  State<LiquidVideoReplacement> createState() =>
      _LiquidVideoReplacementState();
}

class _LiquidVideoReplacementState extends State<LiquidVideoReplacement>
    with SingleTickerProviderStateMixin {
  FragmentProgram? _program;
  late Ticker _ticker;
  double _time = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (mounted) {
        setState(() {
          _time = elapsed.inMilliseconds / 1000.0;
        });
      }
    });
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program =
          await FragmentProgram.fromAsset('shaders/liquid_video.frag');
      if (mounted) {
        setState(() => _program = program);
        _ticker.start();
      }
    } catch (e, stack) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        color: Colors.red.shade900,
        child: Center(
          child: Text(
            'ОШИБКА:\n$_error',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_program == null) {
      return const ColoredBox(color: Colors.deepPurple);
    }

    return CustomPaint(
      size: widget.screenSize, // Явно прокидываем размер экрана
      painter: LiquidPainter(
        shader: _program!.fragmentShader(),
        time: _time,
        size: widget.screenSize,
      ),
    );
  }
}

class LiquidPainter extends CustomPainter {
  final FragmentShader shader;
  final double time;
  final Size size;

  LiquidPainter({
    required this.shader, 
    required this.time,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // Используем переданный размер экрана, если canvasSize вдруг станет (0,0)
    final renderSize = canvasSize.isEmpty ? size : canvasSize;
    
    shader.setFloat(0, renderSize.width);
    shader.setFloat(1, renderSize.height);
    shader.setFloat(2, time);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & renderSize, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidPainter oldDelegate) => true;
}
