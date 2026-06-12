import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A standalone harvesting page with falling particles, collision detection,
/// crane upgrades, and an absorption animation.
class MaterialCollectionPage extends StatefulWidget {
  final void Function(String materialType) onMaterialCollected;

  const MaterialCollectionPage({super.key, required this.onMaterialCollected});

  @override
  State<MaterialCollectionPage> createState() => _MaterialCollectionPageState();
}

class _MaterialCollectionPageState extends State<MaterialCollectionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final math.Random _random = math.Random();
  final List<FallingParticle> _particles = [];

  Size _canvasSize = Size.zero;
  DateTime? _lastFrameTime;
  double _spawnAccumulator = 0.0;
  int craneLevel = 1;
  int _collectedCount = 0;
  String? _warningMessage;
  double _warningTimer = 0.0;
  bool _sizeUpdateScheduled = false;

  ArmState _armState = ArmState.idle;
  FallingParticle? _lockedParticle;
  String? _pendingCollectionType;
  double _clawGrip = 0.0;

  double _shoulderAngle = math.pi;
  double _elbowAngle = 0.0;
  Offset _armBase = Offset.zero;
  Offset _armElbow = Offset.zero;
  Offset _armWrist = Offset.zero;
  Offset _armClaw = Offset.zero;

  static const List<_MaterialSpec> _materialSpecs = [
    _MaterialSpec('Iron', Color(0xFF9AA3B2), Color(0xFF4B5563)),
    _MaterialSpec('Carbon', Color(0xFF6B7280), Color(0xFF111827)),
    _MaterialSpec('Silicon', Color(0xFF7DD3FC), Color(0xFF0284C7)),
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(_tick)
          ..repeat();
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    super.dispose();
  }

  void _tick() {
    final now = DateTime.now();
    final previous = _lastFrameTime ?? now;
    _lastFrameTime = now;
    final dt = (now.difference(previous).inMicroseconds / 1000000.0).clamp(
      0.0,
      0.05,
    );

    if (_canvasSize.width <= 0 || _canvasSize.height <= 0) {
      return;
    }

    _spawnParticles(dt);
    _updateParticles(dt);
    _updateArm(dt);
    _decayWarnings(dt);

    if (mounted) {
      setState(() {});
    }
  }

  void _spawnParticles(double dt) {
    _spawnAccumulator += dt;
    final spawnInterval = math.max(0.11, 0.28 - (craneLevel - 1) * 0.03);
    final targetCount = 18 + craneLevel * 4;

    while (_spawnAccumulator >= spawnInterval) {
      _spawnAccumulator -= spawnInterval;
      if (_particles.length >= targetCount) {
        continue;
      }
      final batchCount = 1 + _random.nextInt(2);
      for (var i = 0; i < batchCount && _particles.length < targetCount; i++) {
        _particles.add(_createParticle());
      }
    }
  }

  FallingParticle _createParticle() {
    final sizeRoll = _random.nextDouble();
    final size = sizeRoll < 0.55
        ? ParticleSize.small
        : (sizeRoll < 0.85 ? ParticleSize.medium : ParticleSize.large);

    final spec = _materialSpecs[_random.nextInt(_materialSpecs.length)];
    final radius = switch (size) {
      ParticleSize.small => 8.0 + _random.nextDouble() * 4.0,
      ParticleSize.medium => 12.0 + _random.nextDouble() * 5.0,
      ParticleSize.large => 18.0 + _random.nextDouble() * 6.0,
    };

    final x =
        radius +
        _random.nextDouble() * math.max(1.0, _canvasSize.width - radius * 2);
    final y = -radius - _random.nextDouble() * 80.0;
    final vy = switch (size) {
      ParticleSize.small => 80.0 + _random.nextDouble() * 55.0,
      ParticleSize.medium => 65.0 + _random.nextDouble() * 45.0,
      ParticleSize.large => 48.0 + _random.nextDouble() * 35.0,
    };
    final vx =
        (_random.nextDouble() - 0.5) *
        switch (size) {
          ParticleSize.small => 24.0,
          ParticleSize.medium => 18.0,
          ParticleSize.large => 12.0,
        };

    return FallingParticle(
      x: x,
      y: y,
      vx: vx,
      vy: vy,
      radius: radius,
      color: spec.baseColor,
      targetResourceType: spec.name,
      size: size,
      wobbleSeed: _random.nextDouble() * math.pi * 2,
    );
  }

  void _updateParticles(double dt) {
    for (final particle in List<FallingParticle>.from(_particles)) {
      particle.timeAlive += dt;
      particle.vy += 18.0 * dt;
      particle.x += particle.vx * dt;
      particle.y += particle.vy * dt;
      particle.x +=
          math.sin(particle.wobbleSeed + particle.timeAlive * 5.0) *
          (0.35 + particle.radius * 0.01);

      if (particle.x < -particle.radius * 2) {
        particle.x = _canvasSize.width + particle.radius * 2;
      } else if (particle.x > _canvasSize.width + particle.radius * 2) {
        particle.x = -particle.radius * 2;
      }

      if (particle.y - particle.radius > _canvasSize.height + 40.0) {
        _particles.remove(particle);
      }
    }
  }

  void _decayWarnings(double dt) {
    if (_warningTimer <= 0.0) {
      _warningMessage = null;
      return;
    }

    _warningTimer -= dt;
    if (_warningTimer <= 0.0) {
      _warningTimer = 0.0;
      _warningMessage = null;
    }
  }

  void _updateArm(double dt) {
    final base = _armBaseAnchor;
    _armBase = base;

    final allowed = craneLevel == 1 ? ParticleSize.small : ParticleSize.large;
    final reach = _armReach;

    if (_armState == ArmState.idle ||
        _lockedParticle == null ||
        !_particles.contains(_lockedParticle)) {
      _lockedParticle = _findBestTarget(allowed, reach);
      _armState = _lockedParticle == null ? ArmState.idle : ArmState.reaching;
    }

    if (craneLevel == 1 && _armState == ArmState.idle) {
      final heavyNearby = _particles.any((p) {
        if (p.size == ParticleSize.small) return false;
        return (Offset(p.x, p.y) - base).distance <= reach * 0.75;
      });
      if (heavyNearby && _warningTimer <= 0.0) {
        _warningMessage = 'TOO HEAVY / UPGRADE NEEDED';
        _warningTimer = 0.7;
      }
    }

    final target = _armState == ArmState.reaching && _lockedParticle != null
      ? Offset(_lockedParticle!.x, _lockedParticle!.y)
      : base.translate(-reach * 0.35, 0.0);

    final targetDir = (target - base);
    final dir = targetDir.distance <= 0.01
      ? const Offset(-1, 0)
      : (targetDir / targetDir.distance);
    final targetForIk = target - dir * _armSegmentC;

    final ik = _solveIK(base, targetForIk, _armSegmentA, _armSegmentB);
    final lerpFactor = (dt * 6.0).clamp(0.0, 1.0);
    _shoulderAngle = _lerpAngle(_shoulderAngle, ik.shoulderAngle, lerpFactor);
    _elbowAngle = _lerpAngle(_elbowAngle, ik.elbowAngle, lerpFactor);

    _armElbow =
        base +
        Offset(
          math.cos(_shoulderAngle) * _armSegmentA,
          math.sin(_shoulderAngle) * _armSegmentA,
        );
    _armWrist =
        _armElbow +
        Offset(
          math.cos(_shoulderAngle + _elbowAngle) * _armSegmentB,
          math.sin(_shoulderAngle + _elbowAngle) * _armSegmentB,
        );
    _armClaw = _armWrist + dir * _armSegmentC;

    if (_armState == ArmState.reaching && _lockedParticle != null) {
      final distance =
          (Offset(_lockedParticle!.x, _lockedParticle!.y) - _armClaw).distance;
      if (distance <= _lockedParticle!.radius + 6.0) {
        _pendingCollectionType = _lockedParticle!.targetResourceType;
        _particles.remove(_lockedParticle);
        _lockedParticle = null;
        _armState = ArmState.returning;
      }
    }

    if (_armState == ArmState.returning) {
      final restPoint = base.translate(-reach * 0.35, 0.0);
      if ((_armClaw - restPoint).distance <= 8.0) {
        _armState = ArmState.idle;
        if (_pendingCollectionType != null) {
          widget.onMaterialCollected(_pendingCollectionType!);
          _collectedCount += 1;
          _pendingCollectionType = null;
        }
      }
    }

    // Claw grip animation
    final double targetGrip = (_armState == ArmState.returning) ? 1.0 : 0.0;
    if (_clawGrip != targetGrip) {
      const double gripSpeed = 6.0; // Closes or opens in ~0.16 seconds
      if (_clawGrip < targetGrip) {
        _clawGrip = math.min(1.0, _clawGrip + dt * gripSpeed);
      } else {
        _clawGrip = math.max(0.0, _clawGrip - dt * gripSpeed);
      }
    }
  }

  FallingParticle? _findBestTarget(ParticleSize allowed, double reach) {
    FallingParticle? best;
    double bestScore = double.infinity;
    final centerX = _canvasSize.width / 2;
    for (final particle in _particles) {
      if (particle.size.index > allowed.index) {
        continue;
      }
      final distance = (Offset(particle.x, particle.y) - _armBase).distance;
      if (distance <= reach) {
        // We evaluate targets by their absolute distance to the center line of the screen.
        // This makes the crane always reach/stretch out to the middle region.
        final score = (particle.x - centerX).abs();
        if (score < bestScore) {
          best = particle;
          bestScore = score;
        }
      }
    }
    return best;
  }

  _IKSolution _solveIK(Offset base, Offset target, double l1, double l2) {
    final dx = target.dx - base.dx;
    final dy = target.dy - base.dy;
    final distance = math.sqrt(dx * dx + dy * dy).clamp(1.0, l1 + l2 - 2.0);
    final cosElbow =
        ((distance * distance) - (l1 * l1) - (l2 * l2)) / (2 * l1 * l2);
    var elbowAngle = math.acos(cosElbow.clamp(-1.0, 1.0));
    // Force elbow to stay in extended range (0.8 to 2.5 radians = wide angle)
    elbowAngle = elbowAngle.clamp(0.8, 2.5);
    final k1 = l1 + l2 * math.cos(elbowAngle);
    final k2 = l2 * math.sin(elbowAngle);
    final shoulderAngle = math.atan2(dy, dx) - math.atan2(k2, k1);
    return _IKSolution(shoulderAngle, elbowAngle);
  }

  double _lerpAngle(double from, double to, double t) {
    var delta = (to - from) % (math.pi * 2);
    if (delta > math.pi) {
      delta -= math.pi * 2;
    }
    return from + delta * t;
  }

  Offset get _armBaseAnchor {
    final baseX = _canvasSize.width - 20.0;
    final baseY = 120.0;
    return Offset(baseX, baseY);
  }

  double get _armSegmentA => 60.0;

  double get _armSegmentB => 150.0;

  double get _armSegmentC => 90.0;

  double get _armReach => _armSegmentA + _armSegmentB + _armSegmentC;

  void _upgradeCrane() {
    setState(() {
      craneLevel += 1;
      _warningMessage = 'CRANE UPGRADED';
      _warningTimer = 0.7;
    });
  }

  void _onCanvasResize(Size size) {
    if (size == _canvasSize || _sizeUpdateScheduled) return;
    _sizeUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sizeUpdateScheduled = false;
      if (!mounted) return;
      setState(() {
        _canvasSize = size;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            _onCanvasResize(size);

            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: MaterialCollectionPainter(
                      particles: _particles,
                      armBase: _armBase,
                      armElbow: _armElbow,
                      armWrist: _armWrist,
                      armClaw: _armClaw,
                      craneLevel: craneLevel,
                      collectedCount: _collectedCount,
                      warningMessage: _warningMessage,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: 75,
                  child: const CustomPaint(
                    painter: StationPlatformPainter(),
                  ),
                ),
                Positioned.fill(
                  child: CraneSpriteLayer(
                    base: _armBase,
                    elbow: _armElbow,
                    wrist: _armWrist,
                    claw: _armClaw,
                    clawGrip: _clawGrip,
                    pendingCollectionType: _pendingCollectionType,
                    scale: 0.6,
                    copies: 4,
                    verticalSpacing: 150,
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      _InfoChip(
                        label: 'CRANE LVL',
                        value: craneLevel.toString(),
                        color: const Color(0xFF00F5D4),
                      ),
                      const SizedBox(width: 10),
                      _InfoChip(
                        label: 'COLLECTED',
                        value: _collectedCount.toString(),
                        color: const Color(0xFFFFD60A),
                      ),
                    ],
                  ),
                ),
                if (_warningMessage != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 170,
                    child: AnimatedOpacity(
                      opacity: _warningTimer.clamp(0.0, 1.0),
                      duration: const Duration(milliseconds: 100),
                      child: Text(
                        _warningMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: ElevatedButton(
                    onPressed: _upgradeCrane,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF00F5D4,
                      ).withOpacity(0.14),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: const Color(0xFF00F5D4).withOpacity(0.45),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Upgrade Crane',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MaterialCollectionPainter extends CustomPainter {
  final List<FallingParticle> particles;
  final Offset armBase;
  final Offset armElbow;
  final Offset armWrist;
  final Offset armClaw;
  final int craneLevel;
  final int collectedCount;
  final String? warningMessage;

  MaterialCollectionPainter({
    required this.particles,
    required this.armBase,
    required this.armElbow,
    required this.armWrist,
    required this.armClaw,
    required this.craneLevel,
    required this.collectedCount,
    required this.warningMessage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawParticles(canvas);
    _drawGroundGlow(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bgRect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF091124), Color(0xFF04050B)],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, paint);

    final starPaint = Paint()..color = Colors.white.withOpacity(0.25);
    final random = math.Random(1);
    for (var i = 0; i < 48; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.6;
      canvas.drawCircle(
        Offset(x, y),
        0.7 + random.nextDouble() * 1.3,
        starPaint,
      );
    }
  }

  void _drawParticles(Canvas canvas) {
    for (final particle in particles) {
      final alpha = (particle.opacity.clamp(0.0, 1.0) * 255).round().clamp(
        0,
        255,
      );
      final fillPaint = Paint()
        ..color = particle.color.withAlpha(alpha)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = Colors.white.withOpacity(
          0.35 * particle.opacity.clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1;

      final rect = Rect.fromCircle(
        center: Offset(particle.x, particle.y),
        radius: particle.radius,
      );

      switch (particle.size) {
        case ParticleSize.small:
          canvas.drawCircle(
            Offset(particle.x, particle.y),
            particle.radius,
            fillPaint,
          );
          canvas.drawCircle(
            Offset(particle.x - 1, particle.y - 1),
            particle.radius * 0.42,
            strokePaint,
          );
          break;
        case ParticleSize.medium:
          final rrect = RRect.fromRectAndRadius(
            rect,
            Radius.circular(particle.radius * 0.28),
          );
          canvas.drawRRect(rrect, fillPaint);
          canvas.drawRRect(rrect.deflate(1.2), strokePaint);
          break;
        case ParticleSize.large:
          final path = Path();
          final w = particle.radius * 2.0;
          final h = particle.radius * 1.7;
          final dx = particle.x - w / 2;
          final dy = particle.y - h / 2;
          path.moveTo(dx + w * 0.10, dy + h * 0.25);
          path.lineTo(dx + w * 0.28, dy);
          path.lineTo(dx + w * 0.74, dy + h * 0.08);
          path.lineTo(dx + w, dy + h * 0.36);
          path.lineTo(dx + w * 0.84, dy + h);
          path.lineTo(dx + w * 0.34, dy + h * 0.92);
          path.lineTo(dx, dy + h * 0.56);
          path.close();
          canvas.drawPath(path, fillPaint);
          canvas.drawPath(path, strokePaint);
          break;
      }

      final labelPainter = TextPainter(
        text: TextSpan(
          text: particle.targetResourceType.substring(0, 1),
          style: TextStyle(
            color: Colors.white.withOpacity(
              0.75 * particle.opacity.clamp(0.0, 1.0),
            ),
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(
          particle.x - labelPainter.width / 2,
          particle.y - labelPainter.height / 2,
        ),
      );
    }
  }

  void _drawGroundGlow(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x2200F5D4), Color(0x0000F5D4)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width / 2, size.height - 100),
              radius: 180,
            ),
          );
    canvas.drawCircle(Offset(size.width / 2, size.height - 100), 180, glow);
  }

  @override
  bool shouldRepaint(covariant MaterialCollectionPainter oldDelegate) {
    return oldDelegate.particles != particles ||
        oldDelegate.craneLevel != craneLevel ||
        oldDelegate.armBase != armBase ||
        oldDelegate.armElbow != armElbow ||
        oldDelegate.armWrist != armWrist ||
        oldDelegate.armClaw != armClaw ||
        oldDelegate.collectedCount != collectedCount ||
        oldDelegate.warningMessage != warningMessage;
  }
}

class FallingParticle {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  Color color;
  final String targetResourceType;
  final ParticleSize size;
  final double wobbleSeed;
  double timeAlive = 0.0;
  bool absorbing = false;
  Offset absorbStart = Offset.zero;
  double absorbStartRadius = 0.0;
  double absorbProgress = 0.0;
  double opacity = 1.0;

  FallingParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
    required this.targetResourceType,
    required this.size,
    required this.wobbleSeed,
  });
}

enum ArmState { idle, reaching, returning }

class _IKSolution {
  final double shoulderAngle;
  final double elbowAngle;

  const _IKSolution(this.shoulderAngle, this.elbowAngle);
}

enum ParticleSize { small, medium, large }

class _MaterialSpec {
  final String name;
  final Color baseColor;
  final Color accentColor;

  const _MaterialSpec(this.name, this.baseColor, this.accentColor);
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.95),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CraneSpriteLayer extends StatelessWidget {
  final Offset base;
  final Offset elbow;
  final Offset wrist;
  final Offset claw;
  final double scale;
  final int copies;
  final double verticalSpacing;
  final double clawGrip;
  final String? pendingCollectionType;

  const CraneSpriteLayer({
    super.key,
    required this.base,
    required this.elbow,
    required this.wrist,
    required this.claw,
    required this.clawGrip,
    required this.pendingCollectionType,
    this.scale = 0.6,
    this.copies = 4,
    this.verticalSpacing = 150,
  });

  Color _getMaterialColor(String type) {
    switch (type) {
      case 'Iron':
        return const Color(0xFF9AA3B2);
      case 'Carbon':
        return const Color(0xFF6B7280);
      case 'Silicon':
        return const Color(0xFF7DD3FC);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (base == Offset.zero && elbow == Offset.zero && claw == Offset.zero) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];
    for (var i = 0; i < copies; i++) {
      final offset = Offset(0, i * verticalSpacing);
      final basePos = base + offset;
      final elbowPos = basePos + (elbow - base) * scale;
      final wristPos = basePos + (wrist - base) * scale;
      final clawPos = basePos + (claw - base) * scale;

      final angle1 = math.atan2(elbowPos.dy - basePos.dy, elbowPos.dx - basePos.dx);
      final angle2 = math.atan2(wristPos.dy - elbowPos.dy, wristPos.dx - elbowPos.dx);
      final angle3 = math.atan2(clawPos.dy - wristPos.dy, clawPos.dx - wristPos.dx);
      final seg1Len = (elbowPos - basePos).distance;
      final seg2Len = (wristPos - elbowPos).distance;
      final seg3Len = (clawPos - wristPos).distance;

      children.addAll([
        Positioned(
          left: basePos.dx - 60 * scale,
          top: basePos.dy - 90 * scale,
          child: SizedBox(
            width: 140 * scale,
            height: 180 * scale,
            child: SvgPicture.asset(
              'assets/crane/base_mount.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          left: basePos.dx - 50 * scale,
          top: basePos.dy - 50 * scale,
          child: Transform.rotate(
            angle: angle1,
            child: SizedBox(
              width: 120 * scale,
              height: 120 * scale,
              child: SvgPicture.asset(
                'assets/crane/gear.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
          left: basePos.dx,
          top: basePos.dy,
          child: Transform.rotate(
            angle: angle1,
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: seg1Len,
              height: 48 * scale,
              child: SvgPicture.asset(
                'assets/crane/arm_segment.svg',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        Positioned(
          left: elbowPos.dx,
          top: elbowPos.dy,
          child: Transform.rotate(
            angle: angle2,
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: seg2Len,
              height: 38 * scale,
              child: SvgPicture.asset(
                'assets/crane/forearm_segment.svg',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        Positioned(
          left: wristPos.dx,
          top: wristPos.dy,
          child: Transform.rotate(
            angle: angle3,
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: seg3Len,
              height: 28 * scale,
              child: SvgPicture.asset(
                'assets/crane/forearm_segment.svg',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        Positioned(
          left: basePos.dx - 10 * scale,
          top: basePos.dy + 10 * scale,
          child: Transform.rotate(
            angle: angle1,
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: seg1Len * 0.55,
              height: 30 * scale,
              child: SvgPicture.asset(
                'assets/crane/piston.svg',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        // Elbow joint gear
        Positioned(
          left: elbowPos.dx - 30 * scale,
          top: elbowPos.dy - 30 * scale,
          child: Transform.rotate(
            angle: angle2,
            child: SizedBox(
              width: 60 * scale,
              height: 60 * scale,
              child: SvgPicture.asset(
                'assets/crane/gear.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        // Wrist joint gear
        Positioned(
          left: wristPos.dx - 22.5 * scale,
          top: wristPos.dy - 22.5 * scale,
          child: Transform.rotate(
            angle: angle3,
            child: SizedBox(
              width: 45 * scale,
              height: 45 * scale,
              child: SvgPicture.asset(
                'assets/crane/gear.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        // Claw connection joint gear
        Positioned(
          left: clawPos.dx - 18 * scale,
          top: clawPos.dy - 18 * scale,
          child: Transform.rotate(
            angle: angle3 * 1.5,
            child: SizedBox(
              width: 36 * scale,
              height: 36 * scale,
              child: SvgPicture.asset(
                'assets/crane/gear.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
          left: clawPos.dx - 60 * scale,
          top: clawPos.dy - 60 * scale,
          child: Transform.rotate(
            angle: angle3,
            child: SizedBox(
              width: 120 * scale,
              height: 120 * scale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Wrist Base
                  Positioned(
                    left: 45 * scale,
                    top: 15 * scale,
                    width: 30 * scale,
                    height: 30 * scale,
                    child: SvgPicture.asset(
                      'assets/crane/claw_wrist.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Left Pincer (Finger)
                  Positioned(
                    left: 26.75 * scale,
                    top: 35 * scale,
                    width: 35 * scale,
                    height: 52.5 * scale,
                    child: Transform.rotate(
                      angle: (1.0 - clawGrip) * 0.45 + clawGrip * (-0.05),
                      alignment: const Alignment(0.5, -1.0),
                      child: SvgPicture.asset(
                        'assets/crane/claw_finger_left.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Right Pincer (Finger)
                  Positioned(
                    left: 58.25 * scale,
                    top: 35 * scale,
                    width: 35 * scale,
                    height: 52.5 * scale,
                    child: Transform.rotate(
                      angle: (1.0 - clawGrip) * (-0.45) + clawGrip * 0.05,
                      alignment: const Alignment(-0.5, -1.0),
                      child: SvgPicture.asset(
                        'assets/crane/claw_finger_right.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Grabbed item (if returning with one)
                  if (pendingCollectionType != null)
                    Positioned(
                      left: 48 * scale,
                      top: 72 * scale,
                      width: 24 * scale,
                      height: 24 * scale,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getMaterialColor(pendingCollectionType!),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getMaterialColor(pendingCollectionType!).withOpacity(0.6),
                              blurRadius: 8 * scale,
                              spreadRadius: 2 * scale,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            pendingCollectionType!.substring(0, 1),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ]);
    }

    return Stack(children: children);
  }
}

class StationPlatformPainter extends CustomPainter {
  const StationPlatformPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // We draw a vertical column of width `size.width` (which is 75.0) from y=0 to y=size.height.
    final rect = Offset.zero & size;

    // 1. Dark metallic background gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF0F172A), // Slate 900
          Color(0xFF1E293B), // Slate 800
          Color(0xFF334155), // Slate 700
          Color(0xFF1E293B), // Slate 800
          Color(0xFF0F172A), // Slate 900
        ],
        stops: [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Beveled left edge with a glowing cyan line
    final glowPaint = Paint()
      ..color = const Color(0xFF00F5D4)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final shadowPaint = Paint()
      ..color = const Color(0xFF00F5D4).withOpacity(0.3)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), shadowPaint);
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), glowPaint);

    // Draw a dark metal divider line on the right edge (x=size.width)
    final borderPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), borderPaint);

    // 3. Panel plates divisions (horizontal cuts) & Rivets
    final cutPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.0;
    final cutHighlightPaint = Paint()
      ..color = const Color(0xFF475569).withOpacity(0.4)
      ..strokeWidth = 1.0;

    final rivetPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.fill;
    final rivetCenterPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    const panelHeight = 120.0;
    final panelCount = (size.height / panelHeight).ceil();

    for (var i = 0; i <= panelCount; i++) {
      final y = i * panelHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), cutPaint);
      canvas.drawLine(Offset(0, y + 1.5), Offset(size.width, y + 1.5), cutHighlightPaint);

      if (i < panelCount) {
        // Left rivets
        canvas.drawCircle(Offset(12, y + 15), 3.0, rivetPaint);
        canvas.drawCircle(Offset(12, y + 15), 1.0, rivetCenterPaint);
        canvas.drawCircle(Offset(12, y + panelHeight - 15), 3.0, rivetPaint);
        canvas.drawCircle(Offset(12, y + panelHeight - 15), 1.0, rivetCenterPaint);

        // Right rivets
        canvas.drawCircle(Offset(size.width - 12, y + 15), 3.0, rivetPaint);
        canvas.drawCircle(Offset(size.width - 12, y + 15), 1.0, rivetCenterPaint);
        canvas.drawCircle(Offset(size.width - 12, y + panelHeight - 15), 3.0, rivetPaint);
        canvas.drawCircle(Offset(size.width - 12, y + panelHeight - 15), 1.0, rivetCenterPaint);
      }
    }

    // 4. Glowing power line in the center of the column
    final conduitGlow = Paint()
      ..color = const Color(0xFFFF9F1C).withOpacity(0.25)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;
    final conduitLine = Paint()
      ..color = const Color(0xFFFF9F1C)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), conduitGlow);
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), conduitLine);

    // Warning hazard stripes at the top and bottom
    _drawHazardStripes(canvas, const Rect.fromLTWH(0, 0, 75, 20));
    _drawHazardStripes(canvas, Rect.fromLTWH(0, size.height - 20, 75, 20));
  }

  void _drawHazardStripes(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    final stripePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);

    canvas.save();
    canvas.clipRect(rect);
    const stripeWidth = 8.0;
    for (var x = rect.left - rect.height; x < rect.right + rect.height; x += stripeWidth * 2) {
      final path = Path()
        ..moveTo(x, rect.top)
        ..lineTo(x + stripeWidth, rect.top)
        ..lineTo(x + stripeWidth - rect.height, rect.bottom)
        ..lineTo(x - rect.height, rect.bottom)
        ..close();
      canvas.drawPath(path, stripePaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
