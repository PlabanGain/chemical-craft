enum ResourceType {
  iron,
  silicon,
  waterIce,
  carbon,
  oxygen,
  nitrogen,
  water,
  co2,
  steel,
  atmosphere,
  hep, // Habitable Environment Points
}

enum MaterialType {
  solid, // Box storage (Iron, Silicon, Carbon, Steel)
  liquid, // Test tube storage (Water Ice, Liquid Water)
  gas, // Capped bottle storage (Oxygen, Nitrogen, CO2, Atmosphere)
}

class Resource {
  final ResourceType type;
  final String name;
  final String symbol;
  final String description;
  final bool isRefined;
  final MaterialType materialType;
  bool unlocked;
  double amount;
  int level; // For upgrading auto-collection rates
  final double baseCollectionRate; // Amount auto-collected per level per second
  final String colorHex; // Sci-fi glow color representation

  Resource({
    required this.type,
    required this.name,
    required this.symbol,
    required this.description,
    required this.isRefined,
    required this.materialType,
    this.unlocked = true,
    this.amount = 0.0,
    this.level = 0,
    required this.baseCollectionRate,
    required this.colorHex,
  });

  // Calculate rate based on level and baseline
  double get collectionRate => level * baseCollectionRate;

  // Max storage capacity set to 100 units per material
  double get capacity => 100.0;

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'amount': amount,
    'level': level,
    'unlocked': unlocked,
  };

  factory Resource.fromJson(Map<String, dynamic> json, Resource template) {
    final savedLevel = json['level'] as int? ?? template.level;
    return Resource(
      type: template.type,
      name: template.name,
      symbol: template.symbol,
      description: template.description,
      isRefined: template.isRefined,
      materialType: template.materialType,
      unlocked:
          json['unlocked'] as bool? ?? (template.unlocked || savedLevel > 0),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      level: savedLevel,
      baseCollectionRate: template.baseCollectionRate,
      colorHex: template.colorHex,
    );
  }

  Resource copyWith({double? amount, int? level}) {
    return Resource(
      type: type,
      name: name,
      symbol: symbol,
      description: description,
      isRefined: isRefined,
      materialType: materialType,
      unlocked: unlocked,
      amount: amount ?? this.amount,
      level: level ?? this.level,
      baseCollectionRate: baseCollectionRate,
      colorHex: colorHex,
    );
  }

  // Create list of template resources
  static List<Resource> createTemplates() {
    return [
      Resource(
        type: ResourceType.iron,
        name: 'Iron',
        symbol: 'Fe',
        description: 'Crucial metallic element extracted from rust-plains.',
        isRefined: false,
        materialType: MaterialType.solid,
        unlocked: true,
        amount: 0.0,
        level: 0, // Manual mining only at the start
        baseCollectionRate: 1.0, // 1 unit per auto miner per second
        colorHex: '0xFF8E9AAF', // Steel blue-grey glow
      ),
      Resource(
        type: ResourceType.silicon,
        name: 'Silicon',
        symbol: 'Si',
        description: 'Semi-metallic crystal used in electronics and shields.',
        isRefined: false,
        materialType: MaterialType.solid,
        unlocked: false,
        amount: 0.0,
        level: 0,
        baseCollectionRate: 1.0,
        colorHex: '0xFFD6CFC7', // Silvery sand glow
      ),
      Resource(
        type: ResourceType.waterIce,
        name: 'Water Ice',
        symbol: 'H₂O Ice',
        description: 'Frozen water glaciers mined from polar caps.',
        isRefined: false,
        materialType: MaterialType.liquid,
        unlocked: false,
        amount: 0.0,
        level: 0,
        baseCollectionRate: 1.0,
        colorHex: '0xFF90E0EF', // Pale cyan glow
      ),
      Resource(
        type: ResourceType.carbon,
        name: 'Carbon',
        symbol: 'C',
        description: 'Organic soot mined from ancient volcanic craters.',
        isRefined: false,
        materialType: MaterialType.solid,
        unlocked: false,
        amount: 0.0,
        level: 0,
        baseCollectionRate: 1.0,
        colorHex: '0xFFFFB5A7', // Dark Amber glow
      ),
      Resource(
        type: ResourceType.oxygen,
        name: 'Oxygen Gas',
        symbol: 'O₂',
        description: 'Vital gas extracted from the planet\'s thin crust.',
        isRefined: false,
        materialType: MaterialType.gas,
        unlocked: false,
        amount: 0.0,
        level: 0,
        baseCollectionRate: 1.0,
        colorHex: '0xFF48CAE4', // Neon sky blue glow
      ),
      Resource(
        type: ResourceType.nitrogen,
        name: 'Nitrogen Gas',
        symbol: 'N₂',
        description: 'Inert atmospheric buffer gathered from high orbit.',
        isRefined: false,
        materialType: MaterialType.gas,
        unlocked: false,
        amount: 0.0,
        level: 0,
        baseCollectionRate: 1.0,
        colorHex: '0xFFB5E2FA', // Cyan mist glow
      ),
      // Refined Resources
      Resource(
        type: ResourceType.water,
        name: 'Liquid Water',
        symbol: 'H₂O',
        description: 'Refined water to fill oceans and sustain bio-life.',
        isRefined: true,
        materialType: MaterialType.liquid,
        unlocked: true,
        amount: 0.0,
        level: 0,
        baseCollectionRate: 0.0,
        colorHex: '0xFF0077B6', // Pure deep blue
      ),
      Resource(
        type: ResourceType.co2,
        name: 'Carbon Dioxide',
        symbol: 'CO₂',
        description: 'Greenhouse gas designed to warm up the icy planet.',
        isRefined: true,
        materialType: MaterialType.gas,
        unlocked: true,
        amount: 0.0,
        level: 0,
        baseCollectionRate: 0.0,
        colorHex: '0xFFF77F00', // Neon heat orange
      ),
      Resource(
        type: ResourceType.steel,
        name: 'Steel Alloy',
        symbol: 'Steel',
        description:
            'Refined steel alloy used in heavy terraforming machinery.',
        isRefined: true,
        materialType: MaterialType.solid,
        unlocked: true,
        amount: 0.0,
        level: 0,
        baseCollectionRate: 0.0,
        colorHex: '0xFFD3D3D3', // Bright metallic silver
      ),
      Resource(
        type: ResourceType.atmosphere,
        name: 'Basic Atmosphere',
        symbol: 'Atmosphere',
        description: 'Thick atmospheric blanket to block radiation.',
        isRefined: true,
        materialType: MaterialType.gas,
        unlocked: true,
        amount: 0.0,
        level: 0,
        baseCollectionRate: 0.0,
        colorHex: '0xFF72EFDD', // Vibrant neon teal
      ),
      Resource(
        type: ResourceType.hep,
        name: 'Habitable Environment Points',
        symbol: 'HEP',
        description: 'Ultimate chemical catalyst to accelerate biosigns.',
        isRefined: true,
        materialType: MaterialType.solid,
        unlocked: true,
        amount: 0.0,
        level: 0,
        baseCollectionRate: 0.0,
        colorHex: '0xFF38B000', // Radiant neon green
      ),
    ];
  }
}
