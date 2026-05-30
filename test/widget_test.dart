import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chemical_craft/main.dart';
import 'package:chemical_craft/providers/game_state.dart';

void main() {
  testWidgets('Planet Terraformer App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameState(),
        child: const PlanetTerraformerApp(),
      ),
    );

    // Verify that the title bar contains the app title text
    expect(find.text('PLANET TERRAFORMER v1.0'), findsOneWidget);
  });
}
