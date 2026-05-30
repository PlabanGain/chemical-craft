import 'package:flutter/material.dart';

class RotatingPlanet extends StatefulWidget {
  final int stage;
  final double waterLevel;
  final double atmosphereLevel;
  final double temperatureLevel;
  final double habitabilityScore;

  const RotatingPlanet({
    Key? key,
    required this.stage,
    required this.waterLevel,
    required this.atmosphereLevel,
    required this.temperatureLevel,
    required this.habitabilityScore,
  }) : super(key: key);

  @override
  State<RotatingPlanet> createState() => _RotatingPlanetState();
}

class _RotatingPlanetState extends State<RotatingPlanet>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // Continuous rotation of the planet
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              // Outer neon atmosphere glow, intensity scales with atmosphereLevel
              BoxShadow(
                color: widget.stage >= 2
                    ? const Color(0xFF00F5D4).withOpacity(
                        0.15 + (widget.atmosphereLevel / 100.0) * 0.25)
                    : const Color(0xFF8E9095).withOpacity(0.08),
                blurRadius: 30 + (widget.atmosphereLevel / 100.0) * 20,
                spreadRadius: 2 + (widget.atmosphereLevel / 100.0) * 8,
              ),
            ],
          ),
          child: CustomPaint(
            painter: PlanetPainter(
              rotation: _rotationController.value,
              stage: widget.stage,
              waterLevel: widget.waterLevel,
              atmosphereLevel: widget.atmosphereLevel,
              temperatureLevel: widget.temperatureLevel,
              habitabilityScore: widget.habitabilityScore,
            ),
          ),
        );
      },
    );
  }
}

class PlanetPainter extends CustomPainter {
  final double rotation;
  final int stage;
  final double waterLevel;
  final double atmosphereLevel;
  final double temperatureLevel;
  final double habitabilityScore;

  PlanetPainter({
    required this.rotation,
    required this.stage,
    required this.waterLevel,
    required this.atmosphereLevel,
    required this.temperatureLevel,
    required this.habitabilityScore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint();

    // 1. Draw Outer Aura Ring (Atmosphere boundary glow)
    if (stage >= 2) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0 + (atmosphereLevel / 100.0) * 4.0;
      paint.color = const Color(0xFF72EFDD).withOpacity(0.3 + (atmosphereLevel / 100.0) * 0.5);
      canvas.drawCircle(center, radius + 1.0, paint);
      paint.style = PaintingStyle.fill;
    }

    // Clip all subsequent drawing inside the planet's circular body
    canvas.save();
    final path = Path()..addOval(rect);
    canvas.clipPath(path);

    // 2. Base Ocean / Bedrock Layer
    // Stage 1 & 2: Dead stone base
    // Stage 3, 4, 5: Ocean blue base (deepness adjusts with waterLevel)
    Color baseColor;
    if (stage <= 2) {
      baseColor = const Color(0xFF4A4B4F); // Dusty dark gray
    } else {
      // Transition from dusty gray to beautiful turquoise blue
      double ratio = (waterLevel / 100.0).clamp(0.0, 1.0);
      baseColor = Color.lerp(
        const Color(0xFF4A4B4F),
        const Color(0xFF003049), // deep ocean blue
        ratio,
      )!;
    }

    paint.color = baseColor;
    canvas.drawRect(rect, paint);

    // 3. Draw Continents / Landmasses (Infinite Horizontal Parallax)
    // We define relative positions for three continents so they scroll and repeat
    final List<ContinentData> continents = [
      ContinentData(relativeX: 0.1, relativeY: 0.3, width: 90, height: 60, seed: 1),
      ContinentData(relativeX: 0.5, relativeY: 0.6, width: 110, height: 80, seed: 2),
      ContinentData(relativeX: 0.8, relativeY: 0.25, width: 70, height: 50, seed: 3),
      ContinentData(relativeX: 0.35, relativeY: 0.15, width: 60, height: 40, seed: 4),
      ContinentData(relativeX: 0.05, relativeY: 0.75, width: 80, height: 55, seed: 5),
    ];

    Color continentColor;
    if (stage == 1) {
      continentColor = const Color(0xFF707379); // Rocky slate gray
    } else if (stage == 2) {
      continentColor = const Color(0xFF867666); // Dry sandy clay/brown
    } else if (stage == 3) {
      continentColor = const Color(0xFFC49A6C); // Warm coast sand
    } else if (stage == 4) {
      // Blended brown/green land
      continentColor = const Color(0xFF6B8E23); // Olive forest green
    } else {
      continentColor = const Color(0xFF38B000); // Lush fluorescent neon green
    }

    paint.color = continentColor;

    // Draw continents scrolled by rotation
    for (var continent in continents) {
      // Standard scrolling offset
      double scrollOffset = rotation * size.width;
      
      // Draw first instance
      _drawContinent(canvas, paint, continent, scrollOffset, size, center);
      
      // Draw wrapping second instance (for continuous wrap)
      _drawContinent(canvas, paint, continent, scrollOffset - size.width, size, center);
      _drawContinent(canvas, paint, continent, scrollOffset + size.width, size, center);
    }

    // 4. Draw Craters / Terrain details (only in early dead stages for sci-fi look)
    if (stage <= 2) {
      paint.color = const Color(0xFF343538).withOpacity(0.5);
      final List<Offset> craters = [
        const Offset(0.2, 0.4),
        const Offset(0.45, 0.7),
        const Offset(0.75, 0.35),
        const Offset(0.1, 0.7),
        const Offset(0.6, 0.2),
      ];

      for (var cr in craters) {
        double scrollX = (cr.dx * size.width + rotation * size.width) % size.width;
        canvas.drawCircle(Offset(scrollX, cr.dy * size.height), 8.0, paint);
        // Inner depth circle
        paint.color = const Color(0xFF222325).withOpacity(0.4);
        canvas.drawCircle(Offset(scrollX - 2.0, cr.dy * size.height - 1.0), 4.0, paint);
        paint.color = const Color(0xFF343538).withOpacity(0.5);
      }
    }

    // 5. Draw Parallax Clouds Layer (Stage 2 and above)
    if (stage >= 2) {
      // Clouds drift at 1.4x faster than terrain for deep spherical parallax
      double cloudScrollOffset = (rotation * 1.3) * size.width;
      paint.color = Colors.white.withOpacity(0.4 + (atmosphereLevel / 100.0) * 0.25);

      final List<CloudData> clouds = [
        CloudData(x: 0.15, y: 0.2, width: 80, height: 14),
        CloudData(x: 0.55, y: 0.5, width: 100, height: 18),
        CloudData(x: 0.8, y: 0.3, width: 60, height: 12),
        CloudData(x: 0.35, y: 0.75, width: 90, height: 16),
        CloudData(x: 0.05, y: 0.6, width: 50, height: 10),
      ];

      for (var cloud in clouds) {
        _drawCloud(canvas, paint, cloud, cloudScrollOffset, size);
        _drawCloud(canvas, paint, cloud, cloudScrollOffset - size.width, size);
        _drawCloud(canvas, paint, cloud, cloudScrollOffset + size.width, size);
      }
    }

    // 6. Draw 3D Radial Sphere Lighting Gradient Overlay (Sun shadow boundary)
    final lightShadowPaint = Paint();
    final shadowGradient = RadialGradient(
      center: const Alignment(-0.35, -0.35), // Sun strikes from top-left
      radius: 1.05,
      colors: [
        Colors.white.withOpacity(0.18), // light reflection highlight
        Colors.transparent, // midtone
        Colors.black.withOpacity(0.85), // dark shadow side (night side)
      ],
      stops: const [0.0, 0.45, 1.0],
    );

    lightShadowPaint.shader = shadowGradient.createShader(rect);
    canvas.drawOval(rect, lightShadowPaint);

    canvas.restore(); // Stop clipping
  }

  // Helper: Draw Continent
  void _drawContinent(Canvas canvas, Paint paint, ContinentData cont,
      double scrollOffset, Size size, Offset center) {
    double posX = (cont.relativeX * size.width + scrollOffset);
    double posY = cont.relativeY * size.height;

    // Draw main body (as a beautiful curved blobs)
    final rect = Rect.fromCenter(
      center: Offset(posX, posY),
      width: cont.width,
      height: cont.height,
    );
    canvas.drawOval(rect, paint);

    // Draw sub-blobs for realism
    final subRect1 = Rect.fromCenter(
      center: Offset(posX - cont.width * 0.3, posY + cont.height * 0.2),
      width: cont.width * 0.5,
      height: cont.height * 0.6,
    );
    canvas.drawOval(subRect1, paint);

    final subRect2 = Rect.fromCenter(
      center: Offset(posX + cont.width * 0.4, posY - cont.height * 0.15),
      width: cont.width * 0.4,
      height: cont.height * 0.4,
    );
    canvas.drawOval(subRect2, paint);
  }

  // Helper: Draw Cloud
  void _drawCloud(Canvas canvas, Paint paint, CloudData cloud,
      double scrollOffset, Size size) {
    double posX = (cloud.x * size.width + scrollOffset);
    double posY = cloud.y * size.height;

    final mainCloud = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(posX, posY), width: cloud.width, height: cloud.height),
      Radius.circular(cloud.height / 2),
    );
    canvas.drawRRect(mainCloud, paint);

    // Minor cloud puffs
    canvas.drawCircle(Offset(posX - cloud.width * 0.2, posY - 3.0), cloud.height * 0.65, paint);
    canvas.drawCircle(Offset(posX + cloud.width * 0.15, posY - 2.0), cloud.height * 0.55, paint);
  }

  @override
  bool shouldRepaint(covariant PlanetPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.stage != stage ||
        oldDelegate.waterLevel != waterLevel ||
        oldDelegate.atmosphereLevel != atmosphereLevel ||
        oldDelegate.temperatureLevel != temperatureLevel ||
        oldDelegate.habitabilityScore != habitabilityScore;
  }
}

class ContinentData {
  final double relativeX;
  final double relativeY;
  final double width;
  final double height;
  final int seed;

  ContinentData({
    required this.relativeX,
    required this.relativeY,
    required this.width,
    required this.height,
    required this.seed,
  });
}

class CloudData {
  final double x;
  final double y;
  final double width;
  final double height;

  CloudData({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}
