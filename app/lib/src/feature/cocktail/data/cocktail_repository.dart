import 'package:shaker_master/src/feature/cocktail/model/cocktail_recipe.dart';

abstract interface class CocktailRepository {
  Future<List<CocktailRecipe>> getCocktails({int limit = 20, int offset = 0, String? searchQuery});

  Future<CocktailRecipe?> getCocktailById(int id);

  Future<CocktailRecipe> createCocktail(CocktailRecipe cocktail);

  Future<CocktailRecipe> updateCocktail(CocktailRecipe cocktail);

  Future<void> deleteCocktail(int id);

  Future<int> getCocktailCount({String? searchQuery});
}
