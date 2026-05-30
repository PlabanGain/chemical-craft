import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../providers/game_state.dart';
import '../models/recipe.dart';
import '../models/resource.dart';
import '../widgets/neon_badge.dart';

class RefineryScreen extends StatelessWidget {
  const RefineryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        final activeCraft = gameState.craftingQueue.isNotEmpty ? gameState.craftingQueue.first : null;

        return SafeArea(
          child: Column(
            children: [
              // 1. Refinery Deck Header
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: const Color(0xFFFFD60A).withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'CHEMICAL REFINERY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 3.0),
                            Text(
                              'REFINE MATERIALS & STRENGTHEN REACTOR CORES',
                              style: TextStyle(
                                color: Color(0xFFFFD60A),
                                fontSize: 9.0,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFD60A).withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.science_outlined,
                            color: Color(0xFFFFD60A),
                            size: 18.0,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    // Energy and points status badges
                    Row(
                      children: [
                        Expanded(
                          child: NeonBadge(
                            label: 'ENERGY',
                            value: '${gameState.energy.toStringAsFixed(1)}/${gameState.maxEnergy.toStringAsFixed(0)}',
                            color: const Color(0xFFFFD60A),
                            icon: Icons.bolt,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: NeonBadge(
                            label: 'COINS',
                            value: gameState.coins.toStringAsFixed(0),
                            color: const Color(0xFF00F5D4),
                            icon: Icons.monetization_on_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Active Reactor Reaction Vessel
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: activeCraft != null
                        ? [const Color(0xFF00F5D4).withOpacity(0.08), const Color(0xFF0077B6).withOpacity(0.12)]
                        : [Colors.white10.withOpacity(0.02), Colors.white10.withOpacity(0.04)],
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: activeCraft != null
                        ? const Color(0xFF00F5D4).withOpacity(0.4)
                        : Colors.white24,
                    width: 1.5,
                  ),
                ),
                child: activeCraft != null
                    ? Row(
                        children: [
                          // Glowing reaction animated spinner
                          const GlowingReactorWidget(),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeCraft.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                const Text(
                                  'Molecular Fusion in progress...',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 10.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                // Tick countdown progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4.0),
                                  child: SizedBox(
                                    height: 6,
                                    child: LinearProgressIndicator(
                                      value: 1.0 - (activeCraft.secondsRemaining / activeCraft.durationSeconds),
                                      backgroundColor: Colors.white10,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F5D4)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${activeCraft.secondsRemaining}s remaining',
                                      style: const TextStyle(
                                        color: Color(0xFF00F5D4),
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => gameState.cancelCraft(0),
                                      child: const Text(
                                        'ABORT & REFUND',
                                        style: TextStyle(
                                          color: Color(0xFFFF3838),
                                          fontSize: 9.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.power_settings_new_rounded, color: Colors.white38, size: 20.0),
                          SizedBox(width: 8.0),
                          Text(
                            'REACTOR COLD: IDLE & READY',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
              ),

              // 3. Middle Scrollable Area: Upgrades shop + Recipes formula List
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lab Upgrades Deck
                      const Text(
                        'REACTOR UPGRADES DECK',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          // Upgrade Speed
                          Expanded(
                            child: _buildReactorUpgradeCard(
                              title: 'SPEED BOOSTER',
                              subtitle: 'Craft times -8%',
                              level: gameState.refineSpeedUpgradeLevel,
                              cost: gameState.getSpeedUpgradeCost(),
                              currencySymbol: 'Steel',
                              canUpgrade: gameState.canUpgradeSpeed(),
                              onTap: () => gameState.upgradeRefineSpeed(),
                              color: const Color(0xFF00F5D4),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          // Upgrade Capacity
                          Expanded(
                            child: _buildReactorUpgradeCard(
                              title: 'CORE OVERLOAD',
                              subtitle: 'Max Energy +5',
                              level: gameState.maxEnergyUpgradeLevel,
                              cost: gameState.getEnergyUpgradeCost(),
                              currencySymbol: 'Si',
                              canUpgrade: gameState.canUpgradeEnergy(),
                              onTap: () => gameState.upgradeMaxEnergy(),
                              color: const Color(0xFFFFD60A),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20.0),
                      const Text(
                        'MOLECULAR SYNTHESIS FORMULAS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // Crafting Formulas List
                      ...gameState.recipes.map((recipe) {
                        final outputResource = gameState.resources.firstWhere((r) => r.type == recipe.outputType);
                        final outputColor = Color(int.parse(outputResource.colorHex));
                        
                        // Check if player has required inputs
                        bool hasIngredients = true;
                        List<Widget> ingredientBadges = [];
                        
                        recipe.inputs.forEach((resType, reqAmount) {
                          final playerRes = gameState.resources.firstWhere((r) => r.type == resType);
                          bool hasEnough = playerRes.amount >= reqAmount;
                          if (!hasEnough) hasIngredients = false;

                          ingredientBadges.add(
                            Container(
                              margin: const EdgeInsets.only(right: 6.0, top: 4.0),
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(4.0),
                                border: Border.all(
                                  color: hasEnough ? Colors.white30 : const Color(0xFFFF3838).withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                '${playerRes.amount.toStringAsFixed(0)}/${reqAmount.toStringAsFixed(0)} ${playerRes.symbol}',
                                style: TextStyle(
                                  color: hasEnough ? Colors.white70 : const Color(0xFFFF3838),
                                  fontSize: 9.0,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          );
                        });

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: outputColor.withOpacity(0.15),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        outputResource.symbol,
                                        style: TextStyle(
                                          color: outputColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                          fontFamily: 'monospace',
                                          shadows: [Shadow(color: outputColor, blurRadius: 4.0)],
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        recipe.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 10.0, color: Colors.white38),
                                        const SizedBox(width: 3.0),
                                        Text(
                                          '${recipe.baseDurationSeconds}s',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 9.0,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                recipe.description,
                                style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                              ),
                              const SizedBox(height: 10.0),
                              // Inputs and Crafting trigger row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      children: ingredientBadges,
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  // Craft Trigger button
                                  InkWell(
                                    onTap: () {
                                      gameState.craftRecipe(recipe);
                                    },
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        color: hasIngredients && gameState.energy >= 3.0
                                            ? outputColor.withOpacity(0.15)
                                            : Colors.white10,
                                        borderRadius: BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: hasIngredients && gameState.energy >= 3.0
                                              ? outputColor.withOpacity(0.5)
                                              : Colors.white24,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.offline_bolt_outlined,
                                            size: 12.0,
                                            color: hasIngredients && gameState.energy >= 3.0
                                                ? outputColor
                                                : Colors.white30,
                                          ),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            'FUSE (3⚡)',
                                            style: TextStyle(
                                              color: hasIngredients && gameState.energy >= 3.0
                                                  ? Colors.white
                                                  : Colors.white30,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Reactor Upgrade panel builder helper
  Widget _buildReactorUpgradeCard({
    required String title,
    required String subtitle,
    required int level,
    required double cost,
    required String currencySymbol,
    required bool canUpgrade,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: canUpgrade ? color.withOpacity(0.35) : Colors.white24,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Lvl $level',
                    style: TextStyle(
                      color: color,
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3.0),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white60, fontSize: 9.0),
              ),
              const SizedBox(height: 10.0),
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(6.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 32,
                  decoration: BoxDecoration(
                    color: canUpgrade ? color.withOpacity(0.15) : Colors.white10,
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: canUpgrade ? color.withOpacity(0.5) : Colors.white24,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'BUY: ${cost.toStringAsFixed(0)} $currencySymbol',
                    style: TextStyle(
                      color: canUpgrade ? Colors.white : Colors.white24,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Glowing Pulsating Reactor Animation Widget
class GlowingReactorWidget extends StatefulWidget {
  const GlowingReactorWidget({Key? key}) : super(key: key);

  @override
  State<GlowingReactorWidget> createState() => _GlowingReactorWidgetState();
}

class _GlowingReactorWidgetState extends State<GlowingReactorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        double glowSize = 35.0 + (_pulseController.value * 12.0);
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00F5D4).withOpacity(0.1),
            border: Border.all(
              color: const Color(0xFF00F5D4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F5D4).withOpacity(0.4),
                blurRadius: glowSize,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Icon(
            Icons.blur_circular,
            color: Color(0xFF00F5D4),
            size: 24,
          ),
        );
      },
    );
  }
}
