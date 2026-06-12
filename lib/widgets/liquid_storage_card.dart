import 'dart:math' as math;
import 'dart:ui';

import 'package:chemical_craft/models/resource.dart' as res_model;
import 'package:chemical_craft/widgets/resource_icon.dart';
import 'package:flutter/material.dart';

class LiquidStorageCard extends StatefulWidget {
  final res_model.Resource resource;

  const LiquidStorageCard({Key? key, required this.resource}) : super(key: key);

  @override
  State<LiquidStorageCard> createState() => _LiquidStorageCardState();
}

class _LiquidStorageCardState extends State<LiquidStorageCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;
    final color = Color(int.parse(resource.colorHex));
    final fill = (resource.amount / resource.capacity).clamp(0.0, 1.0);
    final full = fill >= 0.999;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(18.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0E1320).withOpacity(0.95),
                    const Color(0xFF1B2238).withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(color: color.withOpacity(0.45), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.14),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildMaterialBadge(resource, color),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resource.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                '${resource.amount.toStringAsFixed(1)} / ${resource.capacity.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildLiquidContainer(fill, color, t),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Opacity(
                                  opacity:
                                      0.10 +
                                      (math.sin(t * math.pi * 2) + 1.0) * 0.03,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.0),
                                          Colors.white.withOpacity(0.22),
                                          Colors.white.withOpacity(0.0),
                                        ],
                                        stops: const [0.25, 0.5, 0.75],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999.0),
                            child: Container(
                              height: 7.0,
                              color: Colors.white.withOpacity(0.08),
                              child: Stack(
                                children: [
                                  FractionallySizedBox(
                                    widthFactor: fill,
                                    alignment: Alignment.centerLeft,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            color.withOpacity(0.25),
                                            color,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          full ? 'FULL' : '${(fill * 100).round()}%',
                          style: TextStyle(
                            color: full ? const Color(0xFFFFD60A) : color,
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      _liquidSubtitle(resource),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaterialBadge(res_model.Resource resource, Color color) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.75), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ResourceIcon(type: resource.type, size: 40),
      ),
    );
  }

  Widget _buildLiquidContainer(double fill, Color color, double t) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.18)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.03),
            Colors.white.withOpacity(0.07),
            Colors.white.withOpacity(0.02),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              child: CustomPaint(
                painter: _WavePainter(color: color, fillPercent: fill, time: t),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.35 + (math.sin(t * math.pi * 2) + 1.0) * 0.08,
                child: _buildFloatingBubbles(color, t, fill),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBubbles(Color color, double t, double fill) {
    if (fill < 0.05) return const SizedBox.shrink();
    final bubbleCount = (2 + (fill * 8)).round();
    final particles = List.generate(bubbleCount, (index) {
      final progress = (t + index * 0.13) % 1.0;
      final x =
          16.0 + (index % 4) * 34.0 + math.sin((t * 2 * math.pi) + index) * 6.0;
      final y = 120.0 - progress * (120 * fill);
      final size = 2.0 + (index % 3) * 1.5;
      return Positioned(
        left: x,
        top: y,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.6),
            border: Border.all(color: color.withOpacity(0.8)),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.45), blurRadius: 4),
            ],
          ),
        ),
      );
    });

    return Stack(children: particles);
  }

  String _liquidSubtitle(res_model.Resource resource) {
    switch (resource.type) {
      case res_model.ResourceType.water:
        return 'Purified H2O stored in a cooled containment tank';
      case res_model.ResourceType.waterIce:
        return 'Melted ice slush in a cryogenic flask';
      default:
        return 'Liquid resource containment';
    }
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double fillPercent;
  final double time;

  _WavePainter({
    required this.color,
    required this.fillPercent,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final waveHeight = size.height * (1.0 - fillPercent);
    final waveAmplitude = 8.0;
    final waveFrequency = 1.5;
    final waveSpeed = time * 2 * math.pi;

    final path = Path();
    path.moveTo(0, waveHeight + math.sin(waveSpeed) * waveAmplitude);

    for (double x = 0; x < size.width; x++) {
      final y =
          waveHeight +
          math.sin(waveSpeed + x / size.width * waveFrequency * math.pi) *
              waveAmplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.4), color.withOpacity(0.8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    // Draw top wave highlight
    final highlightPath = Path();
    highlightPath.moveTo(0, waveHeight + math.sin(waveSpeed) * waveAmplitude);
    for (double x = 0; x < size.width; x++) {
      final y =
          waveHeight +
          math.sin(waveSpeed + x / size.width * waveFrequency * math.pi) *
              waveAmplitude;
      highlightPath.lineTo(x, y);
    }

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
