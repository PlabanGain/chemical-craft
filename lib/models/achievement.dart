class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // Emoji representations for sci-fi badges
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isUnlocked': isUnlocked,
      };

  static List<Achievement> createAchievements() {
    return [
      Achievement(
        id: 'ach_iron_age',
        title: 'Rust-Iron Miner',
        description: 'Accumulate 15 units of Raw Iron.',
        icon: '⛏️',
      ),
      Achievement(
        id: 'ach_first_breath',
        title: 'Oxygen Purifier',
        description: 'Extract 15 units of Oxygen Gas.',
        icon: '🌬️',
      ),
      Achievement(
        id: 'ach_water_drop',
        title: 'Liquid Genesis',
        description: 'Synthesize your very first drop of Liquid Water.',
        icon: '💧',
      ),
      Achievement(
        id: 'ach_greenhouse',
        title: 'Atmospheric Blanket',
        description: 'Refine Carbon Dioxide to warm the frozen crust.',
        icon: '🌋',
      ),
      Achievement(
        id: 'ach_steel_forge',
        title: 'Alloy Age',
        description: 'Smelt Steel Alloy in the reaction reactor.',
        icon: '🔩',
      ),
      Achievement(
        id: 'ach_atmosphere',
        title: 'Radiation Shield',
        description: 'Formulate basic Atmosphere to blanket the planet.',
        icon: '🛡️',
      ),
      Achievement(
        id: 'ach_first_life',
        title: 'Biosphere Catalyst',
        description: 'Generate 5 Habitable Environment Points (HEP).',
        icon: '🌱',
      ),
      Achievement(
        id: 'ach_fully_habitable',
        title: 'Planet Terraformed',
        description: 'Successfully transition the planet to a 100% habitable paradise.',
        icon: '🌍',
      ),
    ];
  }
}
