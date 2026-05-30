import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/resource.dart';
import '../models/recipe.dart';
import '../models/achievement.dart';

class ActiveCraft {
  final String recipeId;
  final String name;
  final ResourceType outputType;
  final double outputAmount;
  final int durationSeconds;
  int secondsRemaining;

  ActiveCraft({
    required this.recipeId,
    required this.name,
    required this.outputType,
    required this.outputAmount,
    required this.durationSeconds,
    required this.secondsRemaining,
  });

  Map<String, dynamic> toJson() => {
        'recipeId': recipeId,
        'name': name,
        'outputType': outputType.name,
        'outputAmount': outputAmount,
        'durationSeconds': durationSeconds,
        'secondsRemaining': secondsRemaining,
      };

  factory ActiveCraft.fromJson(Map<String, dynamic> json) {
    return ActiveCraft(
      recipeId: json['recipeId'] as String,
      name: json['name'] as String,
      outputType: ResourceType.values.firstWhere(
        (e) => e.name == json['outputType'],
        orElse: () => ResourceType.water,
      ),
      outputAmount: (json['outputAmount'] as num).toDouble(),
      durationSeconds: json['durationSeconds'] as int,
      secondsRemaining: json['secondsRemaining'] as int,
    );
  }
}

class FloatingNotification {
  final String id;
  final String text;
  final String colorHex;
  final Offset position;

  FloatingNotification({
    required this.id,
    required this.text,
    required this.colorHex,
    required this.position,
  });
}

class GameState extends ChangeNotifier {
  // Game metrics
  List<Resource> _resources = [];
  List<Recipe> _recipes = [];
  List<Achievement> _achievements = [];
  List<ActiveCraft> _craftingQueue = [];
  List<FloatingNotification> _notifications = [];

  double _energy = 10.0;
  double _maxEnergy = 10.0;
  double _energyRegenRate = 0.5; // per second
  double _coins = 25.0;

  // Planet Metrics
  double _waterLevel = 0.0; // 0 to 100
  double _atmosphereLevel = 0.0; // 0 to 100
  double _temperatureLevel = 0.0; // 0 to 100 (percentage of target warm temperature)

  // Upgrade stats
  int _labLevel = 1;
  int _refineSpeedUpgradeLevel = 0; // reduces crafting time
  int _maxEnergyUpgradeLevel = 0; // increases max energy

  // Loop timer
  Timer? _gameLoopTimer;

  // Getters
  List<Resource> get resources => _resources;
  List<Recipe> get recipes => _recipes;
  List<Achievement> get achievements => _achievements;
  List<ActiveCraft> get craftingQueue => _craftingQueue;
  List<FloatingNotification> get notifications => _notifications;

  double get energy => _energy;
  double get maxEnergy => _maxEnergy;
  double get energyRegenRate => _energyRegenRate;
  double get coins => _coins;
  double get terraformPoints => _coins;

  double get waterLevel => _waterLevel;
  double get atmosphereLevel => _atmosphereLevel;
  double get temperatureLevel => _temperatureLevel;

  int get labLevel => _labLevel;
  int get refineSpeedUpgradeLevel => _refineSpeedUpgradeLevel;
  int get maxEnergyUpgradeLevel => _maxEnergyUpgradeLevel;

  // Derived metrics
  double get habitabilityScore {
    // Balanced contribution of water, atmosphere, and temperature
    double score = (_waterLevel + _atmosphereLevel + _temperatureLevel) / 3.0;
    return score.clamp(0.0, 100.0);
  }

  // Planet stage based on current stats
  int get planetStage {
    double hab = habitabilityScore;
    if (hab >= 80.0) return 5; // Stage 5: Lush blue-green habitable globe
    if (hab >= 50.0) return 4; // Stage 4: Green landmasses appear
    if (hab >= 30.0) return 3; // Stage 3: Oceans/water appear
    if (hab >= 10.0) return 2; // Stage 2: Atmosphere / clouds appear
    return 1; // Stage 1: Dead rocky gray planet
  }

  GameState() {
    _initGame();
  }

  void _initGame() {
    _resources = Resource.createTemplates();
    _recipes = Recipe.createRecipes();
    _achievements = Achievement.createAchievements();
    _loadProgress().then((_) {
      _startGameLoop();
    });
  }

  void _startGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    super.dispose();
  }

  // Game tick (runs once per second)
  void _tick() {
    // 1. Auto-generate basic resources
    for (var resource in _resources) {
      if (!resource.isRefined && resource.unlocked && resource.level > 0) {
        resource.amount = min(
          resource.amount + resource.collectionRate,
          resource.capacity,
        );
      }
    }

    // 2. Regenerate energy
    _energy = min(_energy + _energyRegenRate, _maxEnergy);

    // 3. Process Crafting Queue
    if (_craftingQueue.isNotEmpty) {
      final active = _craftingQueue.first;
      active.secondsRemaining--;

      if (active.secondsRemaining <= 0) {
        // Complete crafting!
        _craftingQueue.removeAt(0);
        _completeCraft(active);
      }
    }

    // 4. Verify Achievements
    _checkAchievements();

    notifyListeners();
  }

  // Completes a crafting project
  void _completeCraft(ActiveCraft craft) {
    final targetResource = _resources.firstWhere((r) => r.type == craft.outputType);
    targetResource.amount = min(
      targetResource.amount + craft.outputAmount,
      targetResource.capacity,
    );

    // Award coins for crafting refined compounds
    final coinsEarned = _getRecipeCoinReward(
      craft.outputType,
      craft.outputAmount,
      craft.durationSeconds,
    );
    _coins += coinsEarned;

    triggerNotification(
      'Refined +${craft.outputAmount.toStringAsFixed(0)} ${targetResource.name}! +${coinsEarned.toStringAsFixed(0)} coins',
      targetResource.colorHex,
    );

    saveProgress();
  }

  // Manual Resource Extraction
  void extractResource(ResourceType type, {Offset position = Offset.zero}) {
    final resource = _resources.firstWhere((r) => r.type == type);

    if (!resource.unlocked) {
      triggerNotification('Unlock ${resource.name} first!', '0xFFFFD60A');
      return;
    }
    
    // Manual mining always gives one unit per tap.
    const double tapPower = 1.0;
    resource.amount = min(resource.amount + tapPower, resource.capacity);

    // Trigger visual float-text
    triggerFloatNotification(
      '+${tapPower.toStringAsFixed(1)} ${resource.symbol}',
      resource.colorHex,
      position,
    );

    _checkAchievements();
    notifyListeners();
    saveProgress();
  }

  // Inject Refined Resource to Terraform Planet
  bool injectResource(ResourceType type) {
    final resource = _resources.firstWhere((r) => r.type == type);
    if (resource.amount < 1.0) {
      triggerNotification('Need at least 1.0 ${resource.name} to deploy!', '0xFFFF3838');
      return false;
    }

    resource.amount -= 1.0;

    double ptsGained = 0.0;
    if (type == ResourceType.water) {
      _waterLevel = min(_waterLevel + 4.0, 100.0);
      ptsGained = 15.0;
      triggerNotification('Liquid Water injected into craters! +${ptsGained.toStringAsFixed(0)} coins', resource.colorHex);
    } else if (type == ResourceType.co2) {
      _temperatureLevel = min(_temperatureLevel + 5.0, 100.0);
      ptsGained = 15.0;
      triggerNotification('CO₂ released! Warm greenhouse effect rising. +${ptsGained.toStringAsFixed(0)} coins', resource.colorHex);
    } else if (type == ResourceType.atmosphere) {
      _atmosphereLevel = min(_atmosphereLevel + 4.0, 100.0);
      ptsGained = 20.0;
      triggerNotification('Atmospheric gas dispersed! Pressure rising. +${ptsGained.toStringAsFixed(0)} coins', resource.colorHex);
    } else if (type == ResourceType.steel) {
      // Steel builds shield arrays, boosts energy limits or overall stats
      _maxEnergy = min(_maxEnergy + 2.0, 100.0);
      ptsGained = 25.0;
      triggerNotification('Steel infrastructure erected. Max Energy +2! +${ptsGained.toStringAsFixed(0)} coins', resource.colorHex);
    } else if (type == ResourceType.hep) {
      // HEP is highly premium, gives stats in all three!
      _waterLevel = min(_waterLevel + 8.0, 100.0);
      _atmosphereLevel = min(_atmosphereLevel + 8.0, 100.0);
      _temperatureLevel = min(_temperatureLevel + 8.0, 100.0);
      ptsGained = 80.0;
      triggerNotification('BIOSIGN CATALYST DEPLOYED! Ecosystem rapidly adapting. +${ptsGained.toStringAsFixed(0)} coins', resource.colorHex);
    }

    _coins += ptsGained;
    _checkAchievements();
    notifyListeners();
    saveProgress();
    return true;
  }

  // Refine / Crafting queue system
  bool craftRecipe(Recipe recipe) {
    // 1. Check ingredients
    for (var entry in recipe.inputs.entries) {
      final res = _resources.firstWhere((r) => r.type == entry.key);
      if (res.amount < entry.value) {
        triggerNotification('Insufficient ingredients for ${recipe.name}!', '0xFFFF3838');
        return false;
      }
    }

    // 2. Check Energy requirements (costs 3.0 Energy)
    double energyCost = 3.0;
    if (_energy < energyCost) {
      triggerNotification('Low Energy! Let it recharge.', '0xFFFFD60A');
      return false;
    }

    // 3. Deduct ingredients & energy
    for (var entry in recipe.inputs.entries) {
      final res = _resources.firstWhere((r) => r.type == entry.key);
      res.amount -= entry.value;
    }
    _energy -= energyCost;

    // 4. Calculate actual craft time (reduced by speed upgrade)
    // Speed reduction: -8% duration per level, capped at 60% reduction
    double reduction = min(0.6, _refineSpeedUpgradeLevel * 0.08);
    int finalDuration = max(1, (recipe.baseDurationSeconds * (1.0 - reduction)).round());

    // 5. Add to queue
    _craftingQueue.add(ActiveCraft(
      recipeId: recipe.id,
      name: recipe.name,
      outputType: recipe.outputType,
      outputAmount: recipe.outputAmount,
      durationSeconds: finalDuration,
      secondsRemaining: finalDuration,
    ));

    triggerNotification('Reactor started: ${recipe.name}', '0xFF00F5D4');
    notifyListeners();
    saveProgress();
    return true;
  }

  // Cancel Crafting
  void cancelCraft(int index) {
    if (index >= 0 && index < _craftingQueue.length) {
      final craft = _craftingQueue.removeAt(index);
      // Find recipe to refund half ingredients
      final recipe = _recipes.firstWhere((r) => r.id == craft.recipeId, orElse: () => _recipes.first);
      for (var entry in recipe.inputs.entries) {
        final res = _resources.firstWhere((r) => r.type == entry.key);
        res.amount += entry.value * 0.5; // Half refund
      }
      _energy = min(_energy + 1.5, _maxEnergy); // Refund half energy
      triggerNotification('Craft cancelled. Half ingredients refunded.', '0xFFFF3838');
      notifyListeners();
      saveProgress();
    }
  }

  // --- UPGRADES SHOP ENGINE ---

  double getMinerUnlockCost(ResourceType type) {
    switch (type) {
      case ResourceType.iron:
        return 0.0;
      case ResourceType.silicon:
        return 18.0;
      case ResourceType.waterIce:
        return 20.0;
      case ResourceType.carbon:
        return 28.0;
      case ResourceType.oxygen:
        return 24.0;
      case ResourceType.nitrogen:
        return 32.0;
      default:
        return 0.0;
    }
  }

  bool canUnlockMiner(ResourceType type) {
    final resource = _resources.firstWhere((r) => r.type == type);
    if (resource.unlocked) return false;
    return _coins >= getMinerUnlockCost(type);
  }

  void unlockMiner(ResourceType type) {
    final resource = _resources.firstWhere((r) => r.type == type);
    if (resource.unlocked) {
      triggerNotification('${resource.name} miner is already unlocked.', resource.colorHex);
      return;
    }

    final cost = getMinerUnlockCost(type);
    if (_coins >= cost) {
      _coins -= cost;
      resource.unlocked = true;
      triggerNotification('${resource.name} miner unlocked! Manual mining enabled.', resource.colorHex);
      notifyListeners();
      saveProgress();
    } else {
      triggerNotification('Need ${cost.toStringAsFixed(0)} coins to unlock ${resource.name}!', '0xFFFF3838');
    }
  }

  // Upgrade Auto-Collection Level for a resource
  double getAutoUpgradeCost(ResourceType type) {
    final resource = _resources.firstWhere((r) => r.type == type);
    int lvl = resource.level;
    // Exponential scale; each auto miner adds one unit per second.
    return 12.0 * pow(1.75, lvl);
  }

  bool canUpgradeAuto(ResourceType type) {
    final resource = _resources.firstWhere((r) => r.type == type);
    if (!resource.unlocked) return false;
    final cost = getAutoUpgradeCost(type);
    return _coins >= cost;
  }

  void upgradeAutoCollection(ResourceType type) {
    final resource = _resources.firstWhere((r) => r.type == type);
    if (!resource.unlocked) {
      unlockMiner(type);
      return;
    }

    final cost = getAutoUpgradeCost(type);
    if (_coins >= cost) {
      _coins -= cost;
      resource.level++;
      triggerNotification('${resource.name} auto miner x${resource.level} online!', resource.colorHex);
      notifyListeners();
      saveProgress();
    } else {
      triggerNotification('Need ${cost.toStringAsFixed(0)} coins to add an auto miner!', '0xFFFF3838');
    }
  }

  // Reactor Speed Upgrade
  double getSpeedUpgradeCost() {
    return 20.0 * pow(2.0, _refineSpeedUpgradeLevel);
  }

  bool canUpgradeSpeed() {
    final steelRes = _resources.firstWhere((r) => r.type == ResourceType.steel);
    return steelRes.amount >= getSpeedUpgradeCost();
  }

  void upgradeRefineSpeed() {
    final cost = getSpeedUpgradeCost();
    final steelRes = _resources.firstWhere((r) => r.type == ResourceType.steel);

    if (steelRes.amount >= cost) {
      steelRes.amount -= cost;
      _refineSpeedUpgradeLevel++;
      triggerNotification('Reactor speed boosted! Crafting is faster.', '0xFF00F5D4');
      notifyListeners();
      saveProgress();
    } else {
      triggerNotification('Need ${cost.toStringAsFixed(0)} Steel to upgrade!', '0xFFFF3838');
    }
  }

  double _getRecipeCoinReward(ResourceType outputType, double outputAmount, int durationSeconds) {
    final baseReward = switch (outputType) {
      ResourceType.water => 8.0,
      ResourceType.co2 => 10.0,
      ResourceType.steel => 14.0,
      ResourceType.atmosphere => 18.0,
      ResourceType.hep => 30.0,
      _ => 6.0,
    };

    final durationBonus = max(0.0, (durationSeconds - 3).toDouble() * 1.5);
    return (baseReward + durationBonus) * max(1.0, outputAmount);
  }

  // Energy Capacity Upgrade
  double getEnergyUpgradeCost() {
    return 15.0 * pow(1.8, _maxEnergyUpgradeLevel);
  }

  bool canUpgradeEnergy() {
    final siliconRes = _resources.firstWhere((r) => r.type == ResourceType.silicon);
    return siliconRes.amount >= getEnergyUpgradeCost();
  }

  void upgradeMaxEnergy() {
    final cost = getEnergyUpgradeCost();
    final siliconRes = _resources.firstWhere((r) => r.type == ResourceType.silicon);

    if (siliconRes.amount >= cost) {
      siliconRes.amount -= cost;
      _maxEnergyUpgradeLevel++;
      _maxEnergy += 5.0; // Add 5 to max energy
      _energy = _maxEnergy; // Fully recharge
      _energyRegenRate += 0.1; // Slightly increase speed of regen too
      triggerNotification('Reactor core expanded! Max energy is $_maxEnergy.', '0xFFFFD60A');
      notifyListeners();
      saveProgress();
    } else {
      triggerNotification('Need ${cost.toStringAsFixed(0)} Silicon to upgrade!', '0xFFFF3838');
    }
  }

  // --- FLOATING TEXT NOTIFICATIONS ---

  void triggerFloatNotification(String text, String colorHex, Offset pos) {
    final id = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(100).toString();
    // Shift position slightly up-and-left/right to randomize
    final randomPos = Offset(
      pos.dx + (Random().nextDouble() * 40 - 20),
      pos.dy + (Random().nextDouble() * 20 - 40),
    );
    final notification = FloatingNotification(
      id: id,
      text: text,
      colorHex: colorHex,
      position: randomPos,
    );

    _notifications.add(notification);

    // Auto-remove notification after 800ms
    Timer(const Duration(milliseconds: 1000), () {
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    });
  }

  // Banner Notification at the top
  String? _bannerMessage;
  String _bannerColorHex = '0xFF00F5D4';
  Timer? _bannerTimer;

  String? get bannerMessage => _bannerMessage;
  String get bannerColorHex => _bannerColorHex;

  void triggerNotification(String text, String colorHex) {
    _bannerMessage = text;
    _bannerColorHex = colorHex;
    notifyListeners();

    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 3), () {
      _bannerMessage = null;
      notifyListeners();
    });
  }

  // --- ACHIEVEMENTS CHECKER ---

  void _checkAchievements() {
    for (var ach in _achievements) {
      if (ach.isUnlocked) continue;

      bool shouldUnlock = false;

      switch (ach.id) {
        case 'ach_iron_age':
          shouldUnlock = _resources.firstWhere((r) => r.type == ResourceType.iron).amount >= 15.0;
          break;
        case 'ach_first_breath':
          shouldUnlock = _resources.firstWhere((r) => r.type == ResourceType.oxygen).amount >= 15.0;
          break;
        case 'ach_water_drop':
          shouldUnlock = _resources.firstWhere((r) => r.type == ResourceType.water).amount >= 1.0;
          break;
        case 'ach_greenhouse':
          shouldUnlock = _resources.firstWhere((r) => r.type == ResourceType.co2).amount >= 1.0;
          break;
        case 'ach_steel_forge':
          shouldUnlock = _resources.firstWhere((r) => r.type == ResourceType.steel).amount >= 1.0;
          break;
        case 'ach_atmosphere':
          shouldUnlock = _resources.firstWhere((r) => r.type == ResourceType.atmosphere).amount >= 1.0;
          break;
        case 'ach_first_life':
          shouldUnlock = _resources.firstWhere((r) => r.type == ResourceType.hep).amount >= 5.0;
          break;
        case 'ach_fully_habitable':
          shouldUnlock = habitabilityScore >= 100.0;
          break;
      }

      if (shouldUnlock) {
        ach.isUnlocked = true;
        triggerNotification('🥇 ACHIEVEMENT UNLOCKED: ${ach.title}!', '0xFFFFD60A');
      }
    }
  }

  // RESET PROGRESS (Used for debug or restart)
  void resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _resources = Resource.createTemplates();
    _achievements = Achievement.createAchievements();
    _craftingQueue.clear();
    _energy = 10.0;
    _maxEnergy = 10.0;
    _energyRegenRate = 0.5;
    _coins = 25.0;
    _waterLevel = 0.0;
    _atmosphereLevel = 0.0;
    _temperatureLevel = 0.0;
    _labLevel = 1;
    _refineSpeedUpgradeLevel = 0;
    _maxEnergyUpgradeLevel = 0;
    triggerNotification('Database wiped! Terraforming simulation reset.', '0xFFFF3838');
    notifyListeners();
  }

  // --- LOCAL PERSISTENCE ---

  Future<void> saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final resListJson = _resources.map((r) => r.toJson()).toList();
      final achListJson = _achievements.map((a) => a.toJson()).toList();
      final craftQueueJson = _craftingQueue.map((c) => c.toJson()).toList();

      await prefs.setString('resources', jsonEncode(resListJson));
      await prefs.setString('achievements', jsonEncode(achListJson));
      await prefs.setString('craftingQueue', jsonEncode(craftQueueJson));

      await prefs.setDouble('energy', _energy);
      await prefs.setDouble('maxEnergy', _maxEnergy);
      await prefs.setDouble('energyRegenRate', _energyRegenRate);
      await prefs.setDouble('coins', _coins);

      await prefs.setDouble('waterLevel', _waterLevel);
      await prefs.setDouble('atmosphereLevel', _atmosphereLevel);
      await prefs.setDouble('temperatureLevel', _temperatureLevel);

      await prefs.setInt('labLevel', _labLevel);
      await prefs.setInt('refineSpeedUpgradeLevel', _refineSpeedUpgradeLevel);
      await prefs.setInt('maxEnergyUpgradeLevel', _maxEnergyUpgradeLevel);
    } catch (e) {
      // Silent error catching for headless test environments
    }
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey('resources')) return; // No saved progress yet

      final resString = prefs.getString('resources');
      if (resString != null) {
        final List<dynamic> decoded = jsonDecode(resString);
        for (var json in decoded) {
          final typeStr = json['type'] as String;
          final idx = _resources.indexWhere((r) => r.type.name == typeStr);
          if (idx != -1) {
            _resources[idx] = Resource.fromJson(json, _resources[idx]);
          }
        }
      }

      final achString = prefs.getString('achievements');
      if (achString != null) {
        final List<dynamic> decoded = jsonDecode(achString);
        for (var json in decoded) {
          final id = json['id'] as String;
          final idx = _achievements.indexWhere((a) => a.id == id);
          if (idx != -1) {
            _achievements[idx].isUnlocked = json['isUnlocked'] as bool? ?? false;
          }
        }
      }

      final queueString = prefs.getString('craftingQueue');
      if (queueString != null) {
        final List<dynamic> decoded = jsonDecode(queueString);
        _craftingQueue = decoded.map((c) => ActiveCraft.fromJson(c)).toList();
      }

      _energy = prefs.getDouble('energy') ?? 10.0;
      _maxEnergy = prefs.getDouble('maxEnergy') ?? 10.0;
      _energyRegenRate = prefs.getDouble('energyRegenRate') ?? 0.5;
      _coins = prefs.getDouble('coins') ?? prefs.getDouble('terraformPoints') ?? 25.0;

      _waterLevel = prefs.getDouble('waterLevel') ?? 0.0;
      _atmosphereLevel = prefs.getDouble('atmosphereLevel') ?? 0.0;
      _temperatureLevel = prefs.getDouble('temperatureLevel') ?? 0.0;

      _labLevel = prefs.getInt('labLevel') ?? 1;
      _refineSpeedUpgradeLevel = prefs.getInt('refineSpeedUpgradeLevel') ?? 0;
      _maxEnergyUpgradeLevel = prefs.getInt('maxEnergyUpgradeLevel') ?? 0;
    } catch (e) {
      // Fallback to default template values if load fails
    }
  }
}
