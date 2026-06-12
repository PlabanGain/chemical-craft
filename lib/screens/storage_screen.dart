import 'dart:math' as math;
import 'dart:ui';

import 'package:chemical_craft/widgets/liquid_storage_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/resource.dart' as res_model;
import '../providers/game_state.dart';
import '../widgets/neon_badge.dart';
import '../widgets/resource_icon.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        final solidResources = gameState.resources
            .where((r) => r.materialType == res_model.MaterialType.solid)
            .toList();
        final liquidResources = gameState.resources
            .where((r) => r.materialType == res_model.MaterialType.liquid)
            .toList();
        final gasResources = gameState.resources
            .where((r) => r.materialType == res_model.MaterialType.gas)
            .toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 70.0, 16.0, 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.storage_rounded,
                        color: Color(0xFF00F5D4),
                        size: 24.0,
                      ),
                      const SizedBox(width: 12.0),
                      const Expanded(
                        child: Text(
                          'STORAGE VAULT',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      NeonBadge(
                        label: 'STATUS',
                        value: 'ONLINE',
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
                _buildSolidStorageSection(context, solidResources),
                const SizedBox(height: 28.0),
                _buildLiquidStorageSection(context, liquidResources),
                const SizedBox(height: 28.0),
                _buildGasStorageSection(context, gasResources),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSolidStorageSection(
    BuildContext context,
    List<res_model.Resource> resources,
  ) {
    return _buildSectionShell(
      title: 'SOLID MATERIALS STORAGE',
      subtitle: 'Futuristic warehouse crates and mineral silos',
      icon: Icons.inventory_2_rounded,
      accentColor: const Color(0xFFD3D3D3),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 360 ? 1 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 14.0,
              crossAxisSpacing: 14.0,
              childAspectRatio: columns == 1 ? 2.05 : 1.02,
            ),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              return SolidStorageCrate(resource: resources[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildLiquidStorageSection(
    BuildContext context,
    List<res_model.Resource> resources,
  ) {
    return _buildSectionShell(
      title: 'LIQUID MATERIALS STORAGE',
      subtitle: 'Cryogenic tanks with animated fluid levels',
      icon: Icons.water_drop_rounded,
      accentColor: const Color(0xFF00D4FF),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 360 ? 1 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 14.0,
              crossAxisSpacing: 14.0,
              childAspectRatio: columns == 1 ? 2.05 : 1.02,
            ),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              return LiquidStorageCard(resource: resources[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildGasStorageSection(
    BuildContext context,
    List<res_model.Resource> resources,
  ) {
    return _buildSectionShell(
      title: 'GAS MATERIALS STORAGE',
      subtitle: 'Pressurized tanks with vapor density and pressure gauges',
      icon: Icons.science_rounded,
      accentColor: const Color(0xFF72EFDD),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 360 ? 1 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 14.0,
              crossAxisSpacing: 14.0,
              childAspectRatio: columns == 1 ? 1.18 : 0.95,
            ),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              return GasPressureTank(resource: resources[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionShell({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: title,
          subtitle: subtitle,
          icon: icon,
          accentColor: accentColor,
        ),
        const SizedBox(height: 16.0),
        child,
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: accentColor.withOpacity(0.35), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 18.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accentColor.withOpacity(0.65),
                    fontSize: 9.0,
                    fontStyle: FontStyle.italic,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SolidStorageCrate extends StatefulWidget {
  final res_model.Resource resource;

  const SolidStorageCrate({Key? key, required this.resource}) : super(key: key);

  @override
  State<SolidStorageCrate> createState() => _SolidStorageCrateState();
}

class _SolidStorageCrateState extends State<SolidStorageCrate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
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
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildWarehouseContainer(fill, color, t),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Opacity(
                                opacity:
                                    0.10 +
                                    (math.sin(t * math.pi * 2) + 1.0) * 0.03,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
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
                                  Positioned.fill(
                                    child: Opacity(
                                      opacity:
                                          0.15 +
                                          (math.sin(t * math.pi * 2) + 1.0) *
                                              0.05,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.white,
                                              Colors.transparent,
                                            ],
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
                      _solidSubtitle(resource),
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

  Widget _buildWarehouseContainer(double fill, Color color, double t) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16.0),
                ),
                border: Border(top: BorderSide(color: color.withOpacity(0.12))),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: math.max(18.0, (fill * 120.0).clamp(18.0, 120.0)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [color.withOpacity(0.58), color.withOpacity(0.24)],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildSolidPieces(fill, color, t),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.18),
                              Colors.transparent,
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
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.35 + (math.sin(t * math.pi * 2) + 1.0) * 0.08,
                child: _buildFloatingDust(color, t, fill),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingDust(Color color, double t, double fill) {
    final particles = List.generate(8, (index) {
      final progress = (t + index * 0.13) % 1.0;
      final x =
          16.0 +
          (index % 4) * 34.0 +
          math.sin((t * 2 * math.pi) + index) * (6.0 + fill * 8.0);
      final y = 84.0 - progress * 70.0;
      final size = 2.0 + (index % 3) * 1.2;
      return Positioned(
        left: x,
        top: y,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index.isEven
                ? color.withOpacity(0.45)
                : Colors.white.withOpacity(0.35),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.35), blurRadius: 4),
            ],
          ),
        ),
      );
    });

    return Stack(children: particles);
  }

  Widget _buildSolidPieces(double fill, Color color, double t) {
    // Start with 1 piece if empty, up to 18 pieces if full
    final pieceCount = (1 + (fill * 17)).round().clamp(1, 18);
    final texture = _solidTexture(widget.resource.type);
    final pieces = List.generate(pieceCount, (index) {
      final seed = index * 0.618;
      final row = index ~/ 4;
      final col = index % 4;

      // Move more actively from left to right when empty
      final amplitudeX = 4.0 + (1.0 - fill) * 20.0;
      final x =
          8.0 + col * 20.0 + math.sin((t * 2 * math.pi) + seed) * amplitudeX;

      final amplitudeY = 1.0 + fill * 5.0;
      final y =
          8.0 + row * 16.0 + math.cos((t * 2 * math.pi) + seed) * amplitudeY;

      final size = 10.0 + (index % 3) * 3.0;
      final opacity = 0.45 + fill * 0.55;

      // Dynamic color: Dimmer/desaturated when empty, reaching true texture color when full
      final currentColorLight =
          Color.lerp(Colors.grey.shade700, texture.light, fill) ??
          texture.light;
      final currentColorDark =
          Color.lerp(Colors.grey.shade900, texture.dark, fill) ?? texture.dark;

      return Positioned(
        left: x,
        bottom: y,
        child: Transform.rotate(
          angle:
              (index.isEven ? 1 : -1) *
              0.14 *
              math.sin((t * 2 * math.pi) + seed),
          child: Container(
            width: size,
            height: size * 0.72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  currentColorLight.withOpacity(opacity),
                  currentColorDark.withOpacity(opacity),
                ],
              ),
              border: Border.all(color: texture.highlight.withOpacity(0.55)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1 + fill * 0.25),
                  blurRadius: 4.0 + fill * 6.0,
                ),
              ],
            ),
          ),
        ),
      );
    });

    return Stack(children: pieces);
  }

  ({Color light, Color dark, Color highlight}) _solidTexture(
    res_model.ResourceType type,
  ) {
    switch (type) {
      case res_model.ResourceType.iron:
        return (
          light: const Color(0xFF7E8798),
          dark: const Color(0xFF303742),
          highlight: const Color(0xFFD9E2EC),
        );
      case res_model.ResourceType.silicon:
        return (
          light: const Color(0xFFC7D2FE),
          dark: const Color(0xFF818CF8),
          highlight: const Color(0xFFE0F2FE),
        );
      case res_model.ResourceType.carbon:
        return (
          light: const Color(0xFF2F3542),
          dark: const Color(0xFF0B0F14),
          highlight: const Color(0xFF6B7280),
        );
      case res_model.ResourceType.steel:
        return (
          light: const Color(0xFFE5E7EB),
          dark: const Color(0xFF93A4B8),
          highlight: const Color(0xFFFFFFFF),
        );
      case res_model.ResourceType.hep:
        return (
          light: const Color(0xFF7CFF6B),
          dark: const Color(0xFF1C8F3F),
          highlight: const Color(0xFFDCFFBE),
        );
      default:
        return (
          light: const Color(0xFF8E9AAF),
          dark: const Color(0xFF3A4254),
          highlight: const Color(0xFFEEF2FF),
        );
    }
  }

  String _solidSubtitle(res_model.Resource resource) {
    switch (resource.type) {
      case res_model.ResourceType.iron:
        return 'Dark metallic ore stacks inside a sealed cargo crate';
      case res_model.ResourceType.silicon:
        return 'Crystal shards organized in a clean mineral silo';
      case res_model.ResourceType.carbon:
        return 'Coal-like fragments packed in the warehouse bay';
      case res_model.ResourceType.steel:
        return 'Shiny ingots ready for industrial assembly lines';
      case res_model.ResourceType.hep:
        return 'Catalyst stock sealed in a high-security vault';
      default:
        return 'Industrial solid storage';
    }
  }
}

class GasPressureTank extends StatefulWidget {
  final res_model.Resource resource;

  const GasPressureTank({Key? key, required this.resource}) : super(key: key);

  @override
  State<GasPressureTank> createState() => _GasPressureTankState();
}

class _GasPressureTankState extends State<GasPressureTank>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
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
    final densityLabel = _densityLabel(fill);
    final pressureKpa = (fill * 1000).round();
    final glow = 0.10 + fill * 0.25;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final pulse =
            1.0 + math.sin(t * math.pi * 2) * (fill > 0.95 ? 0.035 : 0.015);
        return Transform.scale(
          scale: pulse,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF08111C).withOpacity(0.95),
                      const Color(0xFF12243A).withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: color.withOpacity(0.55),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(glow),
                      blurRadius: 20,
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
                          _buildGasBadge(resource, color),
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
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildTankBody(fill, color, t),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Opacity(
                                  opacity:
                                      0.12 +
                                      (math.sin(t * math.pi * 2) + 1.0) * 0.06,
                                  child: _buildVaporLayers(fill, color, t),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              right: 10,
                              child: _buildPressureGauge(fill, color, t),
                            ),
                          ],
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
                                child: FractionallySizedBox(
                                  widthFactor: fill,
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 350),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          color.withOpacity(0.20),
                                          color.withOpacity(0.95),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Text(
                            densityLabel,
                            style: TextStyle(
                              color: color,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Pressure: $pressureKpa kPa',
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
          ),
        );
      },
    );
  }

  Widget _buildGasBadge(res_model.Resource resource, Color color) {
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

  Widget _buildTankBody(double fill, Color color, double t) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: color.withOpacity(0.15)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.03),
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0.02),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 14,
            right: 14,
            top: 12,
            bottom: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.03),
                      Colors.white.withOpacity(0.01),
                    ],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 450),
                        height: math.max(
                          18.0,
                          (fill * 180.0).clamp(18.0, 180.0),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              color.withOpacity(0.58),
                              color.withOpacity(0.22),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GasVaporPainter(
                          color: color,
                          t: t,
                          fill: fill,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      right: 14,
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.14),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (fill > 0.72)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Opacity(
                            opacity:
                                0.12 + (math.sin(t * math.pi * 2) + 1.0) * 0.06,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.35),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ],
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
        ],
      ),
    );
  }

  Widget _buildVaporLayers(double fill, Color color, double t) {
    final layers = List.generate(4, (index) {
      final offset = (index * 0.19 + t) % 1.0;
      return Positioned(
        left: 18 + index * 6.0 + math.sin((t * math.pi * 2) + index) * 4.0,
        right: 18 + (3 - index) * 6.0,
        bottom: 22 + offset * 120.0,
        child: Container(
          height: 18 + index * 10.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999.0),
            gradient: RadialGradient(
              colors: [
                color.withOpacity(0.20 + fill * 0.18),
                color.withOpacity(0.02),
              ],
            ),
          ),
        ),
      );
    });

    final sparks = List.generate(6, (index) {
      final p = (t + index * 0.17) % 1.0;
      final x =
          24.0 + (index % 3) * 34.0 + math.sin(t * math.pi * 2 + index) * 7.0;
      final y = 90.0 - p * 130.0;
      return Positioned(
        left: x,
        top: y,
        child: Container(
          width: 2.0 + (index % 2),
          height: 2.0 + (index % 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.55),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.45), blurRadius: 5),
            ],
          ),
        ),
      );
    });

    return Stack(children: [...layers, ...sparks]);
  }

  Widget _buildPressureGauge(double fill, Color color, double t) {
    final angle = -math.pi * 0.9 + fill * math.pi * 1.8;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.25),
        border: Border.all(color: color.withOpacity(0.45), width: 1.2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1.0,
              ),
            ),
          ),
          ...List.generate(6, (index) {
            final tickAngle = -math.pi * 0.85 + index * (math.pi * 1.7 / 5);
            return Transform.rotate(
              angle: tickAngle,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 2,
                  height: index == 3 ? 10 : 7,
                  color: Colors.white.withOpacity(0.35),
                ),
              ),
            );
          }),
          Transform.rotate(
            angle: angle,
            child: Container(
              width: 2.6,
              height: 22,
              decoration: BoxDecoration(
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.8),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          Positioned(
            bottom: 6,
            child: Text(
              '${(fill * 100).round()}%',
              style: TextStyle(
                color: color,
                fontSize: 8.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _densityLabel(double fill) {
    if (fill <= 0.05) return 'EMPTY';
    if (fill < 0.25) return 'LIGHT FOG';
    if (fill < 0.5) return 'MODERATE';
    if (fill < 0.75) return 'THICK GAS';
    return 'DENSE';
  }
}

class _GasVaporPainter extends CustomPainter {
  final Color color;
  final double t;
  final double fill;

  _GasVaporPainter({required this.color, required this.t, required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    final fogPaint = Paint()..style = PaintingStyle.fill;
    final sparkPaint = Paint()
      ..color = Colors.white.withOpacity(0.32)
      ..style = PaintingStyle.fill;

    final baseY = size.height * (0.88 - fill * 0.62);
    for (var i = 0; i < 5; i++) {
      final progress = (t + i * 0.18) % 1.0;
      final y = baseY + progress * size.height * 0.62;
      final x =
          size.width * (0.20 + (i % 3) * 0.22) +
          math.sin((t * math.pi * 2) + i) * 8;
      final radius = 18.0 + i * 7.0;
      fogPaint.color = color.withOpacity(0.06 + fill * 0.18 - i * 0.01);
      canvas.drawCircle(Offset(x, y), radius, fogPaint);
    }

    for (var i = 0; i < 8; i++) {
      final progress = (t + i * 0.11) % 1.0;
      final x =
          size.width * (0.14 + (i % 4) * 0.20) +
          math.sin(progress * math.pi * 2 + i) * 6;
      final y = size.height * 0.92 - progress * size.height * 0.84;
      canvas.drawCircle(Offset(x, y), 1.5 + (i % 2) * 0.8, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GasVaporPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.t != t ||
        oldDelegate.fill != fill;
  }
}
