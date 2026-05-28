import 'package:flutter/material.dart';
import 'dart:ui';

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late Animation<double> _animation1;
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();
    _controller1 =
        AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _controller2 =
        AnimationController(vsync: this, duration: const Duration(seconds: 15));

    _animation1 = Tween<double>(begin: 0, end: 1).animate(_controller1);
    _animation2 = Tween<double>(begin: 0, end: 1).animate(_controller2);

    _controller1.repeat(reverse: true);
    _controller2.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a), // Dark charcoal
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation1,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * 0.1 * _animation1.value,
                left: MediaQuery.of(context).size.width * 0.2 * _animation2.value,
                child: _buildGlowCircle(
                  color: const Color(0xFFff8c00), // Burnt orange
                  radius: 200,
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _animation2,
            builder: (context, child) {
              return Positioned(
                bottom: MediaQuery.of(context).size.height * 0.2 * _animation2.value,
                right: MediaQuery.of(context).size.width * 0.1 * _animation1.value,
                child: _buildGlowCircle(
                  color: const Color(0xFFff4500), // Flame orange
                  radius: 250,
                ),
              );
            },
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowCircle({required Color color, required double radius}) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}
