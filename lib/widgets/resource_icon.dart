import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/resource.dart';

class ResourceIcon extends StatelessWidget {
  final ResourceType type;
  final double size;

  const ResourceIcon({super.key, required this.type, this.size = 24});

  static String assetPathFor(ResourceType type) {
    switch (type) {
      case ResourceType.carbon:
        return 'assets/icons/carbon.svg';
      case ResourceType.iron:
        return 'assets/icons/iron.svg';
      case ResourceType.silicon:
        return 'assets/icons/silicon.svg';
      case ResourceType.steel:
        return 'assets/icons/steel.svg';
      case ResourceType.hep:
        return 'assets/icons/hep.svg';
      case ResourceType.waterIce:
        return 'assets/icons/water_ice.svg';
      case ResourceType.water:
        return 'assets/icons/water.svg';
      case ResourceType.oxygen:
        return 'assets/icons/oxygen.svg';
      case ResourceType.nitrogen:
        return 'assets/icons/nitrogen.svg';
      case ResourceType.co2:
        return 'assets/icons/co2.svg';
      case ResourceType.atmosphere:
        return 'assets/icons/atmosphere.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = assetPathFor(type);
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholderBuilder: (_) => const SizedBox.shrink(),
    );
  }
}
