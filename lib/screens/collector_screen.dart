import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_state.dart';
import '../models/resource.dart';
import '../widgets/resource_card.dart';
import '../widgets/neon_badge.dart';

class CollectorScreen extends StatelessWidget {
  const CollectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        // Filter out basic raw elements
        final rawResources = gameState.resources
            .where((r) => !r.isRefined)
            .toList();

        return Stack(
          children: [
            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Glassmorphic Deck Header
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: const Color(0xFF00F5D4).withOpacity(0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'EXTRACTION DECK',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 3.0),
                                  Text(
                                    'MANUAL FIRST MINER • UNLOCK AUTO MINERS WITH COINS',
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFF00F5D4),
                                      fontSize: 9.0,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.w600,
                                      height: 1.15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Container(
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00F5D4).withOpacity(0.1),
                              ),
                              child: const Icon(
                                Icons.construction_outlined,
                                color: Color(0xFF00F5D4),
                                size: 18.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        // Energy and coin status badges
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: [
                            SizedBox(
                              width: 170.0,
                              child: NeonBadge(
                                label: 'ENERGY',
                                value:
                                    '${gameState.energy.toStringAsFixed(1)}/${gameState.maxEnergy.toStringAsFixed(0)}',
                                color: const Color(0xFFFFD60A),
                                icon: Icons.bolt,
                              ),
                            ),
                            SizedBox(
                              width: 170.0,
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

                  // Resource Cards Scrollable Grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 24.0,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                1, // Full-width cards for mobile layouts
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 1.65,
                          ),
                      itemCount: rawResources.length,
                      itemBuilder: (context, index) {
                        final resource = rawResources[index];
                        final cost = resource.unlocked
                            ? gameState.getAutoUpgradeCost(resource.type)
                            : gameState.getMinerUnlockCost(resource.type);
                        final canUpgrade = resource.unlocked
                            ? gameState.canUpgradeAuto(resource.type)
                            : gameState.canUnlockMiner(resource.type);

                        return ResourceCard(
                          resource: resource,
                          onMine: resource.unlocked
                              ? (Offset globalPos) {
                                  gameState.extractResource(
                                    resource.type,
                                    position: globalPos,
                                  );
                                }
                              : null,
                          onUpgrade: () {
                            if (resource.unlocked) {
                              gameState.upgradeAutoCollection(resource.type);
                            } else {
                              gameState.unlockMiner(resource.type);
                            }
                          },
                          canUpgrade: canUpgrade,
                          upgradeCost: cost,
                          upgradeCurrencyType: ResourceType.iron,
                          upgradeCurrencySymbol: 'COINS',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Floating tap notifications overlay particle layer
            IgnorePointer(
              child: Stack(
                children: gameState.notifications.map((notif) {
                  final color = Color(int.parse(notif.colorHex));
                  return Positioned(
                    left: notif.position.dx,
                    top: notif.position.dy,
                    child: FloatingTextWidget(
                      key: ValueKey(notif.id),
                      text: notif.text,
                      color: color,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Visual Floating Text Animation Widget
class FloatingTextWidget extends StatefulWidget {
  final String text;
  final Color color;

  const FloatingTextWidget({Key? key, required this.text, required this.color})
    : super(key: key);

  @override
  State<FloatingTextWidget> createState() => _FloatingTextWidgetState();
}

class _FloatingTextWidgetState extends State<FloatingTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _opacityAnim;
  late Animation<double> _driftAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _opacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.5, 1.0)),
    );

    _driftAnim = Tween<double>(begin: 0.0, end: -60.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _driftAnim.value),
          child: Opacity(
            opacity: _opacityAnim.value,
            child: Text(
              widget.text,
              style: TextStyle(
                color: widget.color,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                fontFamily: 'monospace',
                shadows: [
                  Shadow(
                    color: widget.color.withOpacity(0.8),
                    blurRadius: 10.0,
                  ),
                  const Shadow(
                    color: Colors.black,
                    blurRadius: 4.0,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
