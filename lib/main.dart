import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'providers/game_state.dart';
import 'models/resource.dart';
import 'widgets/space_background.dart';
import 'screens/storage_screen.dart';
import 'screens/material_collection_page.dart';
import 'screens/refinery_screen.dart';
import 'screens/planet_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const PlanetTerraformerApp(),
    ),
  );
}

class PlanetTerraformerApp extends StatelessWidget {
  const PlanetTerraformerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planet Terraformer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF00F5D4),
        fontFamily:
            'monospace', // Gives a beautiful retro-futuristic hacker-sci-fi look
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuad,
    );
  }

  ResourceType? _materialTypeFromName(String materialType) {
    switch (materialType.toLowerCase()) {
      case 'iron':
        return ResourceType.iron;
      case 'carbon':
        return ResourceType.carbon;
      case 'silicon':
        return ResourceType.silicon;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SpaceBackground(
        child: Stack(
          children: [
            // 1. Swipeable Screens PageView
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                const StorageScreen(),
                Consumer<GameState>(
                  builder: (context, gameState, child) {
                    return MaterialCollectionPage(
                      onMaterialCollected: (materialType) {
                        final resourceType = _materialTypeFromName(
                          materialType,
                        );
                        if (resourceType == null) return;
                        gameState.extractResource(resourceType);
                      },
                    );
                  },
                ),
                const RefineryScreen(),
                const PlanetScreen(),
              ],
            ),

            // 2. Real-time Top Terminal Notification Banner
            Consumer<GameState>(
              builder: (context, gameState, child) {
                if (gameState.bannerMessage == null)
                  return const SizedBox.shrink();

                final bannerColor = Color(int.parse(gameState.bannerColorHex));
                return Positioned(
                  top: 50.0,
                  left: 20.0,
                  right: 20.0,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 200),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, animValue, child) {
                      return Transform.translate(
                        offset: Offset(0, -20.0 * (1.0 - animValue)),
                        child: Opacity(
                          opacity: animValue,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 10.0,
                                sigmaY: 10.0,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: bannerColor,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: bannerColor.withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.terminal_rounded,
                                      color: bannerColor,
                                      size: 16.0,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Expanded(
                                      child: Text(
                                        gameState.bannerMessage!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: bannerColor,
                                              blurRadius: 2.0,
                                            ),
                                          ],
                                        ),
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
                  ),
                );
              },
            ),

            // 3. Top Console Title & Control bar (safe for status bar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Container(
                  height: 50.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.radar_rounded,
                              color: Color(0xFF00F5D4),
                              size: 16.0,
                            ),
                            SizedBox(width: 8.0),
                            Flexible(
                              child: Text(
                                'PLANET TERRAFORMER v1.0',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Settings/Wipe database command trigger
                      GestureDetector(
                        onTap: () => _showResetDialog(context),
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.04),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.settings_backup_restore_rounded,
                            color: Colors.white54,
                            size: 14.0,
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
      ),
      // 4. Futuristic Bottom Nav Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Visual Bottom Navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.only(
        bottom: 12.0,
        top: 6.0,
        left: 16.0,
        right: 16.0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: Colors.white12, width: 1.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.storage_rounded, 'Storage'),
                _buildNavItem(1, Icons.construction_outlined, 'Mining'),
                _buildNavItem(2, Icons.science_outlined, 'Reactor'),
                _buildNavItem(3, Icons.public_outlined, 'Planet'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    Color navColor = isSelected ? const Color(0xFF00F5D4) : Colors.white38;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF00F5D4).withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00F5D4).withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Icon(icon, color: navColor, size: 20.0),
          ),
          const SizedBox(height: 3.0),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: navColor,
              fontSize: 8.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // Database Wipe/Reset Confirmation Dialog
  void _showResetDialog(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            backgroundColor: const Color(0xFF161A1D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: const BorderSide(color: Color(0xFFFF3838), width: 1.5),
            ),
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFFF3838)),
                SizedBox(width: 8.0),
                Text(
                  'SYSTEM HARD RESET',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF3838),
                  ),
                ),
              ],
            ),
            content: const Text(
              'This operation will wipe out all stockpiled resources, chemical reactor speeds, upgraded collectors, and planet metrics. Proceed with simulation reset?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'ABORT',
                  style: TextStyle(color: Colors.white38, fontSize: 11.0),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3838).withOpacity(0.2),
                  side: const BorderSide(color: Color(0xFFFF3838)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  gameState.resetProgress();
                  Navigator.of(ctx).pop();
                },
                child: const Text(
                  'WIPE DATA',
                  style: TextStyle(
                    color: Color(0xFFFF3838),
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
