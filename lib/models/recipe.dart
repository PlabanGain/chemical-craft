import 'resource.dart';

class Recipe {
  final String id;
  final String name;
  final String description;
  final Map<ResourceType, double> inputs;
  final ResourceType outputType;
  final double outputAmount;
  final int baseDurationSeconds; // Time taken in seconds

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.inputs,
    required this.outputType,
    required this.outputAmount,
    required this.baseDurationSeconds,
  });

  // Returns list of available crafting recipes
  static List<Recipe> createRecipes() {
    return [
      Recipe(
        id: 'refine_water',
        name: 'Synthesize Liquid Water',
        description: 'Melt Water Ice glaciers and combine with Oxygen to produce liquid water.',
        inputs: {
          ResourceType.waterIce: 2.0,
          ResourceType.oxygen: 1.0,
        },
        outputType: ResourceType.water,
        outputAmount: 1.0,
        baseDurationSeconds: 3,
      ),
      Recipe(
        id: 'refine_co2',
        name: 'Release Carbon Dioxide',
        description: 'Combine Carbon and Oxygen to trigger a warming greenhouse gas shield.',
        inputs: {
          ResourceType.carbon: 2.0,
          ResourceType.oxygen: 2.0,
        },
        outputType: ResourceType.co2,
        outputAmount: 1.0,
        baseDurationSeconds: 4,
      ),
      Recipe(
        id: 'refine_steel',
        name: 'Smelt Steel Alloy',
        description: 'Forge metallic Iron with pure Carbon to yield durable building plating.',
        inputs: {
          ResourceType.iron: 3.0,
          ResourceType.carbon: 1.0,
        },
        outputType: ResourceType.steel,
        outputAmount: 1.0,
        baseDurationSeconds: 5,
      ),
      Recipe(
        id: 'refine_atmosphere',
        name: 'Synthesize Atmosphere',
        description: 'Combine Nitrogen and Oxygen into a gas shield to block space rays.',
        inputs: {
          ResourceType.nitrogen: 3.0,
          ResourceType.oxygen: 1.0,
        },
        outputType: ResourceType.atmosphere,
        outputAmount: 1.0,
        baseDurationSeconds: 6,
      ),
      Recipe(
        id: 'refine_hep',
        name: 'Formulate Catalyst (HEP)',
        description: 'Merge Liquid Water and basic Atmosphere to spark biological growth.',
        inputs: {
          ResourceType.water: 1.0,
          ResourceType.atmosphere: 1.0,
        },
        outputType: ResourceType.hep,
        outputAmount: 1.0,
        baseDurationSeconds: 8,
      ),
    ];
  }
}
