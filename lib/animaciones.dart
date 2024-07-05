// ignore_for_file: library_private_types_in_public_api

import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 13, 0, 126),
                Color.fromARGB(255, 102, 0, 118),
              ],
            ),
          ),
          child: Stack(
            children: [
              StarAnimation(animation: _animation),
            ],
          ),
        );
      },
    );
  }
}

class StarAnimation extends StatelessWidget {
  final Animation<double> animation;

  const StarAnimation({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: StarrySkyPainter(animation.value),
          child: Container(),
        );
      },
    );
  }
}

class StarrySkyPainter extends CustomPainter {
  final double animationValue;

  StarrySkyPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const int starCount = 50;

    for (int i = 0; i < starCount; i++) {
      final double starSize = 1.0 + Random().nextDouble() * 2.0;
      final double x = Random().nextDouble() * size.width;
      final double y = Random().nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}