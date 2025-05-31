import 'package:meta/meta.dart';
import 'package:shaker_master/src/feature/cocktail/model/cocktail_recipe.dart';

@immutable
sealed class CocktailEvent {
  const CocktailEvent();
}

final class CocktailLoadRequested extends CocktailEvent {
  const CocktailLoadRequested({this.searchQuery});

  final String? searchQuery;
}

final class CocktailLoadMoreRequested extends CocktailEvent {
  const CocktailLoadMoreRequested();
}

final class CocktailSearchRequested extends CocktailEvent {
  const CocktailSearchRequested(this.query);

  final String query;
}

final class CocktailCreateRequested extends CocktailEvent {
  const CocktailCreateRequested(this.cocktail);

  final CocktailRecipe cocktail;
}

final class CocktailUpdateRequested extends CocktailEvent {
  const CocktailUpdateRequested(this.cocktail);

  final CocktailRecipe cocktail;
}

final class CocktailDeleteRequested extends CocktailEvent {
  const CocktailDeleteRequested(this.id);

  final int id;
}

final class CocktailRefreshRequested extends CocktailEvent {
  const CocktailRefreshRequested();
}
