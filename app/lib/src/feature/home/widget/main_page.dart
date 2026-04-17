import 'package:flutter/material.dart';
import 'package:shaker_master/src/feature/auth/widget/login_screen.dart';
import 'package:shaker_master/src/feature/gemma_test/widget/test_gemma_screen.dart';
import 'package:shaker_master/src/feature/shader_lab/widget/shader_lab_screen.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sandbox Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Login Screen'),
          ),
          // Add more navigation buttons here as new screens are developed
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const GemmaTestScreen()),
              );
            },
            child: const Text('Flutter Gemma Test'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ShaderLabScreen()),
              );
            },
            child: const Text('Shader Lab (Rust ripples)'),
          ),
        ],
      ),
    );
  }
}
