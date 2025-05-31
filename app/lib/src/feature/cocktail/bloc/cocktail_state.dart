import 'package:meta/meta.dart';
import 'package:shaker_master/src/feature/cocktail/model/cocktail_recipe.dart';

@immutable
sealed class CocktailState {
  const CocktailState();
}

final class CocktailInitial extends CocktailState {
  const CocktailInitial();
}

final class CocktailLoading extends CocktailState {
  const CocktailLoading();
}

final class CocktailLoaded extends CocktailState {
  const CocktailLoaded({
    required this.cocktails,
    required this.hasReachedMax,
    required this.totalCount,
    this.searchQuery,
  });

  final List<CocktailRecipe> cocktails;
  final bool hasReachedMax;
  final int totalCount;
  final String? searchQuery;

  CocktailLoaded copyWith({
    List<CocktailRecipe>? cocktails,
    bool? hasReachedMax,
    int? totalCount,
    String? searchQuery,
  }) {
    return CocktailLoaded(
      cocktails: cocktails ?? this.cocktails,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CocktailLoaded &&
        other.cocktails == cocktails &&
        other.hasReachedMax == hasReachedMax &&
        other.totalCount == totalCount &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    return Object.hash(cocktails, hasReachedMax, totalCount, searchQuery);
  }
}

final class CocktailLoadingMore extends CocktailState {
  const CocktailLoadingMore({required this.cocktails, required this.totalCount, this.searchQuery});

  final List<CocktailRecipe> cocktails;
  final int totalCount;
  final String? searchQuery;
}

final class CocktailError extends CocktailState {
  const CocktailError(this.message);

  final String message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CocktailError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
