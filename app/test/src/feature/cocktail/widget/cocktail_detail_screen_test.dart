import 'package:app_database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shaker_master/src/feature/cocktail/data/cocktail_repository.dart';
import 'package:shaker_master/src/feature/cocktail/model/cocktail_recipe.dart';
import 'package:shaker_master/src/feature/cocktail/widget/cocktail_detail_screen.dart';
import 'package:shaker_master/src/feature/initialization/model/dependencies_container.dart';
import 'package:shaker_master/src/feature/initialization/widget/dependencies_scope.dart';

import 'cocktail_list_screen_test.mocks.dart';

void main() {
  group('CocktailDetailScreen', () {
    late MockCocktailRepository mockRepository;

    setUp(() {
      mockRepository = MockCocktailRepository();
    });

    // Note: Loading state test skipped due to timer cleanup issues in test environment

    testWidgets('golden test - loaded state with easy cocktail', (tester) async {
      final now = DateTime.now();
      final testCocktail = CocktailRecipe(
        id: 1,
        name: 'Mojito',
        description:
            'A refreshing Cuban cocktail made with white rum, lime juice, sugar, mint, and soda water.',
        instructions:
            'Muddle mint leaves with lime juice and sugar. Add white rum and fill with ice. Top with soda water and garnish with mint.',
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
            name: 'Fresh lime juice',
            amount: '1 oz',
            isOptional: false,
          ),
          CocktailIngredient(
            id: 3,
            cocktailId: 1,
            name: 'Simple syrup',
            amount: '0.5 oz',
            isOptional: false,
          ),
          CocktailIngredient(
            id: 4,
            cocktailId: 1,
            name: 'Fresh mint leaves',
            amount: '6-8 leaves',
            isOptional: false,
          ),
          CocktailIngredient(
            id: 5,
            cocktailId: 1,
            name: 'Soda water',
            amount: 'to top',
            isOptional: false,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      when(mockRepository.getCocktailById(1)).thenAnswer((_) async => testCocktail);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: DependenciesScope(
            dependencies: _TestDependencies(mockRepository),
            child: const CocktailDetailScreen(cocktailId: 1),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CocktailDetailScreen),
        matchesGoldenFile('golden/cocktail_detail_easy.png'),
      );
    });

    testWidgets('golden test - loaded state with hard cocktail', (tester) async {
      final now = DateTime.now();
      final testCocktail = CocktailRecipe(
        id: 2,
        name: 'Ramos Gin Fizz',
        description:
            'A complex classic cocktail requiring extended shaking technique and perfect balance.',
        instructions:
            'Combine gin, lemon juice, lime juice, sugar, cream, egg white, and orange flower water in a shaker. Shake vigorously for 2 minutes. Add ice and shake for another minute. Double strain into a collins glass and top with soda water.',
        difficulty: CocktailDifficulty.hard,
        preparationTimeMinutes: 15,
        ingredients: const [
          CocktailIngredient(id: 6, cocktailId: 2, name: 'Gin', amount: '2 oz', isOptional: false),
          CocktailIngredient(
            id: 7,
            cocktailId: 2,
            name: 'Fresh lemon juice',
            amount: '0.5 oz',
            isOptional: false,
          ),
          CocktailIngredient(
            id: 8,
            cocktailId: 2,
            name: 'Fresh lime juice',
            amount: '0.5 oz',
            isOptional: false,
          ),
          CocktailIngredient(
            id: 9,
            cocktailId: 2,
            name: 'Superfine sugar',
            amount: '1 tbsp',
            isOptional: false,
          ),
          CocktailIngredient(
            id: 10,
            cocktailId: 2,
            name: 'Heavy cream',
            amount: '1 oz',
            isOptional: false,
          ),
          CocktailIngredient(
            id: 11,
            cocktailId: 2,
            name: 'Egg white',
            amount: '1 whole',
            isOptional: false,
          ),
          CocktailIngredient(
            id: 12,
            cocktailId: 2,
            name: 'Orange flower water',
            amount: '3 drops',
            isOptional: true,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      when(mockRepository.getCocktailById(2)).thenAnswer((_) async => testCocktail);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: DependenciesScope(
            dependencies: _TestDependencies(mockRepository),
            child: const CocktailDetailScreen(cocktailId: 2),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CocktailDetailScreen),
        matchesGoldenFile('golden/cocktail_detail_hard.png'),
      );
    });

    testWidgets('golden test - error state', (tester) async {
      when(mockRepository.getCocktailById(999)).thenThrow(Exception('Cocktail not found'));

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: DependenciesScope(
            dependencies: _TestDependencies(mockRepository),
            child: const CocktailDetailScreen(cocktailId: 999),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CocktailDetailScreen),
        matchesGoldenFile('golden/cocktail_detail_error.png'),
      );
    });
  });
}

base class _TestDependencies extends TestDependenciesContainer {
  const _TestDependencies(this._cocktailRepository);

  final CocktailRepository _cocktailRepository;

  @override
  CocktailRepository get cocktailRepository => _cocktailRepository;
}
