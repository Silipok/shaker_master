import 'package:app_database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shaker_master/src/feature/cocktail/model/cocktail_recipe.dart';
import 'package:shaker_master/src/feature/cocktail/widget/cocktail_card.dart';

void main() {
  group('CocktailCard', () {
    late CocktailRecipe testCocktail;

    setUp(() {
      final now = DateTime.now();
      testCocktail = CocktailRecipe(
        id: 1,
        name: 'Mojito',
        description: 'A refreshing Cuban cocktail',
        instructions: 'Muddle mint with lime juice and sugar...',
        difficulty: CocktailDifficulty.easy,
        preparationTimeMinutes: 5,
        ingredients: const [
          CocktailIngredient(
            id: 1,
            cocktailId: 1,
            name: 'White rum',
            amount: '2 oz',
            isOptional: false,
          ),
          CocktailIngredient(
            id: 2,
            cocktailId: 1,
            name: 'Fresh mint',
            amount: '6-8 leaves',
            isOptional: false,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );
    });

    testWidgets('renders cocktail information correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: CocktailCard(cocktail: testCocktail, onTap: () {}))),
      );

      expect(find.text('Mojito'), findsOneWidget);
      expect(find.text('A refreshing Cuban cocktail'), findsOneWidget);
      expect(find.text('5 min'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('2 ingredients'), findsOneWidget);
    });

    testWidgets('golden test - easy difficulty cocktail', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: CocktailCard(cocktail: testCocktail, onTap: () {}),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(CocktailCard),
        matchesGoldenFile('golden/cocktail_card_easy.png'),
      );
    });

    testWidgets('golden test - hard difficulty cocktail', (tester) async {
      final hardCocktail = testCocktail.copyWith(
        name: 'Ramos Gin Fizz',
        description: 'A complex classic cocktail requiring technique',
        difficulty: CocktailDifficulty.hard,
        preparationTimeMinutes: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: CocktailCard(cocktail: hardCocktail, onTap: () {}),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(CocktailCard),
        matchesGoldenFile('golden/cocktail_card_hard.png'),
      );
    });

    testWidgets('golden test - cocktail without description', (tester) async {
      final simpleeCocktail = testCocktail.copyWith();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: CocktailCard(cocktail: simpleeCocktail, onTap: () {}),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(CocktailCard),
        matchesGoldenFile('golden/cocktail_card_no_description.png'),
      );
    });
  });
}
