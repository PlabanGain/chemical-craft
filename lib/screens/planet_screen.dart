import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../providers/game_state.dart';
import '../models/resource.dart';
import '../widgets/rotating_planet.dart';
import '../widgets/neon_badge.dart';

class PlanetScreen extends StatelessWidget {
  const PlanetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        // Find counts of refined materials in inventory
        final waterCount = gameState.resources.firstWhere((r) => r.type == ResourceType.water).amount;
        final co2Count = gameState.resources.firstWhere((r) => r.type == ResourceType.co2).amount;
        final atmCount = gameState.resources.firstWhere((r) => r.type == ResourceType.atmosphere).amount;
        final steelCount = gameState.resources.firstWhere((r) => r.type == ResourceType.steel).amount;
        final hepCount = gameState.resources.firstWhere((r) => r.type == ResourceType.hep).amount;

        // Stage Title mapping
        String stageTitle = 'Stage 1: DEAD DESERT';
        String stageDesc = 'A barren, frozen wasteland stripped of atmosphere and liquid water.';
        Color stageColor = const Color(0xFF8E9095);

        switch (gameState.planetStage) {
          case 2:
            stageTitle = 'Stage 2: ATMOSPHERE SHIELD';
            stageDesc = 'Clouds are forming. Basic atmospheric blanket is filtering solar radiation.';
            stageColor = const Color(0xFF72EFDD);
            break;
          case 3:
            stageTitle = 'Stage 3: OCEAN EXPANSION';
            stageDesc = 'Sub-surface ice is melting. Deep turquoise oceans are filling craters.';
            stageColor = const Color(0xFF0077B6);
            break;
          case 4:
            stageTitle = 'Stage 4: BIOSPHERE SEEDLING';
            stageDesc = 'Green flora patches are spreading across landmasses under warm skies.';
            stageColor = const Color(0xFF38B000);
            break;
          case 5:
            stageTitle = 'Stage 5: VIBRANT NEO TERRA';
            stageDesc = 'A lush, blue-green habitable biosphere! Ecosystem has achieved self-sustainability.';
            stageColor = const Color(0xFF00F5D4);
            break;
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                // 1. Interactive 3D Planet Display & Percentage
                const SizedBox(height: 12.0),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating planet CustomPainter
                      RotatingPlanet(
                        stage: gameState.planetStage,
                        waterLevel: gameState.waterLevel,
                        atmosphereLevel: gameState.atmosphereLevel,
                        temperatureLevel: gameState.temperatureLevel,
                        habitabilityScore: gameState.habitabilityScore,
                      ),
                      // Percentage dial overlay in top corner of planet boundary
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // 2. Stage Info Panel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Text(
                        stageTitle,
                        style: TextStyle(
                          color: stageColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          shadows: [Shadow(color: stageColor, blurRadius: 8.0)],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        stageDesc,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // 3. Stats Meters Deck
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'PLANETARY METRICS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          NeonBadge(
                            label: 'HABITABILITY',
                            value: '${gameState.habitabilityScore.toStringAsFixed(1)}%',
                            color: const Color(0xFF00F5D4),
                          )
                        ],
                      ),
                      const SizedBox(height: 14.0),
                      // Water Level meter
                      _buildMetricProgress(
                        label: 'HYDROSPHERE (WATER)',
                        value: gameState.waterLevel,
                        color: const Color(0xFF0077B6),
                        icon: Icons.water_drop_outlined,
                      ),
                      const SizedBox(height: 12.0),
                      // Atmosphere level meter
                      _buildMetricProgress(
                        label: 'ATMOSPHERE THICKNESS',
                        value: gameState.atmosphereLevel,
                        color: const Color(0xFF72EFDD),
                        icon: Icons.cloud_queue_outlined,
                      ),
                      const SizedBox(height: 12.0),
                      // Temperature level meter
                      _buildMetricProgress(
                        label: 'SURFACE TEMPERATURE',
                        value: gameState.temperatureLevel,
                        color: const Color(0xFFF77F00),
                        icon: Icons.thermostat_outlined,
                        customSuffix: '${(50.0 + (gameState.temperatureLevel / 100.0) * 238.0).toStringAsFixed(0)}K',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16.0),

                // 4. Terraform Deploy Console (Spend refined elements)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'TERRAFORM INJECTION CONSOLE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                    children: [
                      // Release CO2
                      _buildDeployCard(
                        title: 'RELEASE CO₂',
                        desc: '+5% Temp',
                        amount: co2Count,
                        color: const Color(0xFFF77F00),
                        icon: Icons.fireplace_outlined,
                        onTap: () => gameState.injectResource(ResourceType.co2),
                      ),
                      // Release Water
                      _buildDeployCard(
                        title: 'INJECT WATER',
                        desc: '+4% Ocean',
                        amount: waterCount,
                        color: const Color(0xFF0077B6),
                        icon: Icons.opacity_rounded,
                        onTap: () => gameState.injectResource(ResourceType.water),
                      ),
                      // Release Atmosphere
                      _buildDeployCard(
                        title: 'DISPERSE GAS',
                        desc: '+4% Gas Layer',
                        amount: atmCount,
                        color: const Color(0xFF72EFDD),
                        icon: Icons.air_rounded,
                        onTap: () => gameState.injectResource(ResourceType.atmosphere),
                      ),
                      // Construct Grid arrays (Steel)
                      _buildDeployCard(
                        title: 'STEEL INFRA',
                        desc: '+2 Max Energy',
                        amount: steelCount,
                        color: const Color(0xFFD3D3D3),
                        icon: Icons.domain_rounded,
                        onTap: () => gameState.injectResource(ResourceType.steel),
                      ),
                      // Deploy Catalyst
                      _buildDeployCard(
                        title: 'BIO-CATALYST',
                        desc: '+8% All Stats',
                        amount: hepCount,
                        color: const Color(0xFF38B000),
                        icon: Icons.spa_outlined,
                        onTap: () => gameState.injectResource(ResourceType.hep),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20.0),

                // 5. Milestone Achievements Grid
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PLANETARY PROGRESS MILESTONES',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 2.1,
                  ),
                  itemCount: gameState.achievements.length,
                  itemBuilder: (context, index) {
                    final ach = gameState.achievements[index];
                    final borderGlow = ach.isUnlocked
                        ? const Color(0xFFFFD60A).withOpacity(0.5)
                        : Colors.white24;

                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: ach.isUnlocked
                            ? const Color(0xFFFFD60A).withOpacity(0.04)
                            : Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: borderGlow, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Text(
                            ach.icon,
                            style: TextStyle(
                              fontSize: 22,
                              color: ach.isUnlocked ? null : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ach.title,
                                  style: TextStyle(
                                    color: ach.isUnlocked ? Colors.white : Colors.white30,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  ach.description,
                                  style: TextStyle(
                                    color: ach.isUnlocked ? Colors.white54 : Colors.white24,
                                    fontSize: 8.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Builder Helper: metric bars
  Widget _buildMetricProgress({
    required String label,
    required double value,
    required Color color,
    required IconData icon,
    String? customSuffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 12.0, color: color),
                const SizedBox(width: 4.0),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 9.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              customSuffix ?? '${value.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        ClipRRect(
          borderRadius: BorderRadius.circular(3.0),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: value / 100.0,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  // Builder Helper: Deploy console cards
  Widget _buildDeployCard({
    required String title,
    required String desc,
    required double amount,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    bool hasStock = amount >= 1.0;
    return InkWell(
      onTap: hasStock ? onTap : null,
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: hasStock ? color.withOpacity(0.06) : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: hasStock ? color.withOpacity(0.4) : Colors.white12,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.0,
              color: hasStock ? color : Colors.white24,
            ),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: TextStyle(
                color: hasStock ? Colors.white : Colors.white30,
                fontSize: 9.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              desc,
              style: TextStyle(
                color: hasStock ? color : Colors.white24,
                fontSize: 7.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: hasStock ? color.withOpacity(0.15) : Colors.white10,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                'Stock: ${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: hasStock ? Colors.white : Colors.white24,
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
