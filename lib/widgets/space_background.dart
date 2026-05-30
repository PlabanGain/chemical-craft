import 'dart:math';
import 'package:flutter/material.dart';

class SpaceBackground extends StatefulWidget {
  final Widget child;
  const SpaceBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<StarParticle> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Initialize 60 star particles with random attributes
    for (int i = 0; i < 65; i++) {
      _stars.add(StarParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2.2 + 0.5,
        speed: _random.nextDouble() * 0.015 + 0.005,
        opacity: _random.nextDouble() * 0.7 + 0.3,
        color: _random.nextBool()
            ? const Color(0xFF90E0EF) // light neon blue
            : (_random.nextBool()
                ? const Color(0xFFFFB5A7) // warm star peach
                : const Color(0xFFFFFFFF)), // pure white star
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Shift star positions on each tick
        for (var star in _stars) {
          star.y += star.speed * 0.1; // Drift downward slowly
          if (star.y > 1.0) {
            star.y = 0.0;
            star.x = _random.nextDouble();
          }
        }

        return CustomPaint(
          painter: SpacePainter(stars: _stars),
          child: widget.child,
        );
      },
    );
  }
}

class StarParticle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final Color color;

  StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

class SpacePainter extends CustomPainter {
  final List<StarParticle> stars;

  SpacePainter({required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 1. Draw Deep Space Background Gradient
    final rect = Offset.zero & size;
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.2,
      colors: [
        const Color(0xFF03045E).withOpacity(0.9), // Dark Blue space nebula core
        const Color(0xFF000000), // Pure void outer bounds
      ],
      stops: const [0.0, 1.0],
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
    paint.shader = null;

    // 2. Draw Stars
    for (var star in stars) {
      final xPos = star.x * size.width;
      final yPos = star.y * size.height;

      // Glow effect around brighter stars
      if (star.size > 1.8) {
        paint.color = star.color.withOpacity(star.opacity * 0.3);
        canvas.drawCircle(Offset(xPos, yPos), star.size * 2.5, paint);
      }

      paint.color = star.color.withOpacity(star.opacity);
      canvas.drawCircle(Offset(xPos, yPos), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SpacePainter oldDelegate) => true;
}
