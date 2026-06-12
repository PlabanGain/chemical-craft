import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/resource.dart';
import 'resource_icon.dart';

class LiquidTestTube extends StatefulWidget {
  final ResourceType? type;
  final String name;
  final String symbol;
  final double amount;
  final double capacity;
  final Color liquidColor;
  final Color glassColor;

  const LiquidTestTube({
    Key? key,
    this.type,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.capacity,
    required this.liquidColor,
    this.glassColor = const Color(0xFF2A5F7F),
  }) : super(key: key);

  @override
  State<LiquidTestTube> createState() => _LiquidTestTubeState();
}

class _LiquidTestTubeState extends State<LiquidTestTube>
    with TickerProviderStateMixin {
  late AnimationController _fillController;
  late AnimationController _waveController;
  late AnimationController _bubbleController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _fillController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _fillAnimation = Tween<double>(begin: 0, end: _getFillPercentage()).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic),
    );

    _fillController.forward();
  }

  @override
  void didUpdateWidget(LiquidTestTube oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      final newFillPercentage = _getFillPercentage();
      _fillAnimation =
          Tween<double>(
            begin: _fillAnimation.value,
            end: newFillPercentage,
          ).animate(
            CurvedAnimation(
              parent: _fillController,
              curve: Curves.easeOutCubic,
            ),
          );
      _fillController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fillController.dispose();
    _waveController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  double _getFillPercentage() => (widget.amount / widget.capacity).clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    final percentage = _getFillPercentage();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Test Tube Container
        Container(
          width: 80,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.liquidColor.withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glass outer border with gradient
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.liquidColor.withOpacity(0.8),
                    width: 2,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.glassColor.withOpacity(0.3),
                      widget.glassColor.withOpacity(0.1),
                    ],
                  ),
                ),
              ),

              // Animated Liquid Fill
              AnimatedBuilder(
                animation: _fillAnimation,
                builder: (context, child) {
                  return Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                      child: Column(
                        children: [
                          // Wave Animation at Top Surface
                          SizedBox(
                            width: 76,
                            height: 8,
                            child: AnimatedBuilder(
                              animation: _waveController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: WavePainter(
                                    wavePhase:
                                        _waveController.value * 2 * math.pi,
                                    color: widget.liquidColor,
                                  ),
                                );
                              },
                            ),
                          ),
                          // Liquid Fill
                          Container(
                            width: 76,
                            height: (_fillAnimation.value * 132).clamp(0, 132),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  widget.liquidColor.withOpacity(0.8),
                                  widget.liquidColor.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Rising Bubbles
              if (percentage > 0)
                AnimatedBuilder(
                  animation: _bubbleController,
                  builder: (context, child) {
                    return Stack(
                      children: List.generate(3, (index) {
                        final bubbleProgress =
                            (_bubbleController.value + (index * 0.33)) % 1.0;
                        final bubbleHeight = 132 * _fillAnimation.value;
                        return Positioned(
                          bottom: bubbleHeight * bubbleProgress + 10,
                          left: 20 + (index * 20.0),
                          child: Opacity(
                            opacity: math.sin(bubbleProgress * math.pi) * 0.6,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

              // Glass Reflection Highlight
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  width: 16,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Percentage Display
        AnimatedBuilder(
          animation: _fillAnimation,
          builder: (context, child) {
            final displayPercentage = (_fillAnimation.value * 100)
                .toStringAsFixed(0);
            return Text(
              '$displayPercentage%',
              style: TextStyle(
                color: widget.liquidColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: widget.liquidColor.withOpacity(0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Material Name & Symbol
        Text(
          widget.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
        if (widget.type != null)
          Opacity(
            opacity: 0.95,
            child: ResourceIcon(type: widget.type!, size: 16),
          )
        else
          Text(
            widget.symbol,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.liquidColor.withOpacity(0.8),
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),

        const SizedBox(height: 8),

        // Capacity Info
        Text(
          '${widget.amount.toStringAsFixed(1)}/${widget.capacity.toStringAsFixed(0)} units',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 7,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final double wavePhase;
  final Color color;

  WavePainter({required this.wavePhase, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    const waveCount = 2;
    const waveHeight = 2.0;

    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / size.width;
      final y =
          size.height -
          math.sin(normalizedX * 2 * math.pi * waveCount + wavePhase) *
              waveHeight;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase;
  }
}
