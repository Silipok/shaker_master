import 'package:app_database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shaker_master/src/feature/cocktail/bloc/cocktail_bloc.dart';
import 'package:shaker_master/src/feature/cocktail/bloc/cocktail_event.dart';
import 'package:shaker_master/src/feature/cocktail/data/cocktail_repository.dart';
import 'package:shaker_master/src/feature/cocktail/model/cocktail_recipe.dart';
import 'package:shaker_master/src/feature/cocktail/widget/cocktail_list_screen.dart';

import 'cocktail_list_screen_test.mocks.dart';

@GenerateMocks([CocktailRepository])
void main() {
  group('CocktailListScreen', () {
    late MockCocktailRepository mockRepository;
    late CocktailBloc cocktailBloc;

    setUp(() {
      mockRepository = MockCocktailRepository();
      cocktailBloc = CocktailBloc(mockRepository);
    });

    tearDown(() {
      cocktailBloc.close();
    });

    testWidgets('golden test - empty state', (tester) async {
      when(mockRepository.getCocktails(limit: anyNamed('limit'))).thenAnswer((_) async => []);
      when(mockRepository.getCocktailCount()).thenAnswer((_) async => 0);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: BlocProvider.value(value: cocktailBloc, child: const CocktailListScreen()),
        ),
      );

      cocktailBloc.add(const CocktailLoadRequested());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CocktailListScreen),
        matchesGoldenFile('golden/cocktail_list_empty.png'),
      );
    });

    testWidgets('golden test - loading state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: BlocProvider.value(value: cocktailBloc, child: const CocktailListScreen()),
        ),
      );

      await expectLater(
        find.byType(CocktailListScreen),
        matchesGoldenFile('golden/cocktail_list_loading.png'),
      );
    });

    testWidgets('golden test - loaded state with cocktails', (tester) async {
      final now = DateTime.now();
      final mockCocktails = [
        CocktailRecipe(
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
          ],
          createdAt: now,
          updatedAt: now,
        ),
        CocktailRecipe(
          id: 2,
          name: 'Old Fashioned',
          description: 'A classic whiskey cocktail',
          instructions: 'Muddle sugar with bitters...',
          difficulty: CocktailDifficulty.medium,
          preparationTimeMinutes: 3,
          ingredients: const [
            CocktailIngredient(
              id: 2,
              cocktailId: 2,
              name: 'Bourbon',
              amount: '2 oz',
              isOptional: false,
            ),
          ],
          createdAt: now,
          updatedAt: now,
        ),
      ];

      when(
        mockRepository.getCocktails(limit: anyNamed('limit')),
      ).thenAnswer((_) async => mockCocktails);
      when(mockRepository.getCocktailCount()).thenAnswer((_) async => 2);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: BlocProvider.value(value: cocktailBloc, child: const CocktailListScreen()),
        ),
      );

      cocktailBloc.add(const CocktailLoadRequested());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CocktailListScreen),
        matchesGoldenFile('golden/cocktail_list_loaded.png'),
      );
    });
  });
}
