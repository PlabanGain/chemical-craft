import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/resource.dart';
import 'resource_icon.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;
  final void Function(Offset)? onMine;
  final VoidCallback? onUpgrade;
  final bool canUpgrade;
  final double upgradeCost;
  final ResourceType upgradeCurrencyType;
  final String upgradeCurrencySymbol;

  const ResourceCard({
    Key? key,
    required this.resource,
    this.onMine,
    this.onUpgrade,
    this.canUpgrade = false,
    this.upgradeCost = 0.0,
    this.upgradeCurrencyType = ResourceType.iron,
    required this.upgradeCurrencySymbol,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(int.parse(resource.colorHex));
    double capacityPercent = (resource.amount / resource.capacity).clamp(
      0.0,
      1.0,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: themeColor.withOpacity(0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: themeColor.withOpacity(0.04),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Symbol badge & resource descriptors
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Circular neon symbol badge
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: themeColor.withOpacity(0.1),
                            border: Border.all(color: themeColor, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withOpacity(0.2),
                                blurRadius: 6,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ResourceIcon(type: resource.type, size: 40),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        // Resource Name & Level descriptor
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
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                resource.isRefined
                                    ? 'Refined Compound'
                                    : (!resource.unlocked
                                          ? 'Miner Locked'
                                          : (resource.level == 0
                                                ? 'Manual Miner'
                                                : 'Auto Miners x${resource.level}')),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: resource.isRefined
                                      ? const Color(0xFF72EFDD)
                                      : (!resource.unlocked
                                            ? Colors.amberAccent
                                            : Colors.white70),
                                  fontSize: 11.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!resource.isRefined && !resource.unlocked)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.lock_outline,
                              size: 16.0,
                              color: Colors.amberAccent.withOpacity(0.9),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Current stock count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        resource.amount.toStringAsFixed(1),
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          shadows: [
                            Shadow(
                              color: themeColor.withOpacity(0.5),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '/ ${resource.capacity.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 10.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              // Subtitle description of the material
              Text(
                resource.description,
                style: const TextStyle(color: Colors.white54, fontSize: 11.0),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10.0),
              // Capacity Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: capacityPercent,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              // Production metrics
              if (!resource.isRefined)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      resource.unlocked && resource.level > 0
                          ? 'Auto: +${resource.collectionRate.toStringAsFixed(0)}/s'
                          : 'Auto: OFF',
                      style: TextStyle(
                        color: themeColor.withOpacity(0.8),
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      resource.unlocked ? 'Tap: +1.0' : 'Tap: LOCKED',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12.0),
              // Control Actions row: Gather (Mine) & Upgrade Extractor
              Row(
                children: [
                  // Gather manually (onMine trigger) - MINE BUTTON
                  if (onMine != null)
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          final global = details.globalPosition;
                          onMine?.call(global);
                        },
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                themeColor.withOpacity(0.2),
                                themeColor.withOpacity(0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: themeColor.withOpacity(0.6),
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.bolt,
                                size: 14.0,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                resource.unlocked
                                    ? (resource.level == 0 ? 'MINE' : 'EXTRACT')
                                    : 'LOCKED',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (onMine != null && onUpgrade != null)
                    const SizedBox(width: 10.0),
                  // Upgrade Autogeneration (onUpgrade trigger)
                  if (onUpgrade != null)
                    Expanded(
                      flex: 5,
                      child: InkWell(
                        onTap: onUpgrade,
                        borderRadius: BorderRadius.circular(8.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 38,
                          decoration: BoxDecoration(
                            color: canUpgrade
                                ? (resource.unlocked
                                      ? const Color(
                                          0xFF00F5D4,
                                        ).withOpacity(0.15)
                                      : Colors.amber.withOpacity(0.15))
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: canUpgrade
                                  ? (resource.unlocked
                                        ? const Color(
                                            0xFF00F5D4,
                                          ).withOpacity(0.5)
                                        : Colors.amber.withOpacity(0.5))
                                  : Colors.white24,
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                !resource.unlocked
                                    ? 'UNLOCK MINER'
                                    : (resource.level == 0
                                          ? 'BUY AUTO MINER'
                                          : 'ADD AUTO MINER'),
                                style: TextStyle(
                                  color: canUpgrade
                                      ? (resource.unlocked
                                            ? const Color(0xFF00F5D4)
                                            : Colors.amberAccent)
                                      : Colors.white38,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0,
                                ),
                              ),
                              Text(
                                resource.unlocked
                                    ? 'Cost: ${upgradeCost.toStringAsFixed(0)} $upgradeCurrencySymbol'
                                    : 'Unlock: ${upgradeCost.toStringAsFixed(0)} $upgradeCurrencySymbol',
                                style: TextStyle(
                                  color: canUpgrade
                                      ? Colors.white70
                                      : Colors.white24,
                                  fontSize: 9.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
