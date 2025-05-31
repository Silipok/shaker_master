import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:shaker_master/src/feature/cocktail/data/cocktail_repository.dart';
import 'package:shaker_master/src/feature/cocktail/model/cocktail_recipe.dart';

final class LocalCocktailRepository implements CocktailRepository {
  const LocalCocktailRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<CocktailRecipe>> getCocktails({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) async {
    var query = _database.select(_database.cocktails);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query..where((c) => c.name.like('%$searchQuery%'));
    }

    query =
        query
          ..orderBy([(c) => OrderingTerm.desc(c.createdAt)])
          ..limit(limit, offset: offset);

    final cocktails = await query.get();

    final cocktailRecipes = <CocktailRecipe>[];
    for (final cocktail in cocktails) {
      final ingredients =
          await (_database.select(_database.ingredients)
            ..where((i) => i.cocktailId.equals(cocktail.id))).get();

      cocktailRecipes.add(_mapToModel(cocktail, ingredients));
    }

    return cocktailRecipes;
  }

  @override
  Future<CocktailRecipe?> getCocktailById(int id) async {
    final cocktail =
        await (_database.select(_database.cocktails)
          ..where((c) => c.id.equals(id))).getSingleOrNull();

    if (cocktail == null) return null;

    final ingredients =
        await (_database.select(_database.ingredients)
          ..where((i) => i.cocktailId.equals(id))).get();

    return _mapToModel(cocktail, ingredients);
  }

  @override
  Future<CocktailRecipe> createCocktail(CocktailRecipe cocktail) async {
    return await _database.transaction(() async {
      final cocktailId = await _database
          .into(_database.cocktails)
          .insert(
            CocktailsCompanion.insert(
              name: cocktail.name,
              description: Value(cocktail.description),
              instructions: cocktail.instructions,
              imageUrl: Value(cocktail.imageUrl),
              difficulty: cocktail.difficulty,
              preparationTimeMinutes: cocktail.preparationTimeMinutes,
            ),
          );

      for (final ingredient in cocktail.ingredients) {
        await _database
            .into(_database.ingredients)
            .insert(
              IngredientsCompanion.insert(
                cocktailId: cocktailId,
                name: ingredient.name,
                amount: ingredient.amount,
                isOptional: Value(ingredient.isOptional),
              ),
            );
      }

      return (await getCocktailById(cocktailId))!;
    });
  }

  @override
  Future<CocktailRecipe> updateCocktail(CocktailRecipe cocktail) async {
    return await _database.transaction(() async {
      await (_database.update(_database.cocktails)..where((c) => c.id.equals(cocktail.id))).write(
        CocktailsCompanion(
          name: Value(cocktail.name),
          description: Value(cocktail.description),
          instructions: Value(cocktail.instructions),
          imageUrl: Value(cocktail.imageUrl),
          difficulty: Value(cocktail.difficulty),
          preparationTimeMinutes: Value(cocktail.preparationTimeMinutes),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await (_database.delete(_database.ingredients)
        ..where((i) => i.cocktailId.equals(cocktail.id))).go();

      for (final ingredient in cocktail.ingredients) {
        await _database
            .into(_database.ingredients)
            .insert(
              IngredientsCompanion.insert(
                cocktailId: cocktail.id,
                name: ingredient.name,
                amount: ingredient.amount,
                isOptional: Value(ingredient.isOptional),
              ),
            );
      }

      return (await getCocktailById(cocktail.id))!;
    });
  }

  @override
  Future<void> deleteCocktail(int id) async {
    await _database.transaction(() async {
      await (_database.delete(_database.ingredients)..where((i) => i.cocktailId.equals(id))).go();
      await (_database.delete(_database.cocktails)..where((c) => c.id.equals(id))).go();
    });
  }

  @override
  Future<int> getCocktailCount({String? searchQuery}) async {
    var query = _database.selectOnly(_database.cocktails)
      ..addColumns([_database.cocktails.id.count()]);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query..where(_database.cocktails.name.like('%$searchQuery%'));
    }

    final result = await query.getSingle();
    return result.read(_database.cocktails.id.count()) ?? 0;
  }

  CocktailRecipe _mapToModel(Cocktail cocktail, List<Ingredient> ingredients) {
    return CocktailRecipe(
      id: cocktail.id,
      name: cocktail.name,
      description: cocktail.description,
      instructions: cocktail.instructions,
      imageUrl: cocktail.imageUrl,
      difficulty: cocktail.difficulty,
      preparationTimeMinutes: cocktail.preparationTimeMinutes,
      ingredients:
          ingredients
              .map(
                (i) => CocktailIngredient(
                  id: i.id,
                  cocktailId: i.cocktailId,
                  name: i.name,
                  amount: i.amount,
                  isOptional: i.isOptional,
                ),
              )
              .toList(),
      createdAt: cocktail.createdAt,
      updatedAt: cocktail.updatedAt,
    );
  }
}
