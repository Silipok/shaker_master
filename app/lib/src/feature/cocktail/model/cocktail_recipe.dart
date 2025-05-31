import 'package:app_database/app_database.dart';
import 'package:meta/meta.dart';

@immutable
final class CocktailRecipe {
  const CocktailRecipe({
    required this.id,
    required this.name,
    required this.instructions,
    required this.difficulty,
    required this.preparationTimeMinutes,
    required this.ingredients,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String? description;
  final String instructions;
  final String? imageUrl;
  final CocktailDifficulty difficulty;
  final int preparationTimeMinutes;
  final List<CocktailIngredient> ingredients;
  final DateTime createdAt;
  final DateTime updatedAt;

  CocktailRecipe copyWith({
    int? id,
    String? name,
    String? description,
    String? instructions,
    String? imageUrl,
    CocktailDifficulty? difficulty,
    int? preparationTimeMinutes,
    List<CocktailIngredient>? ingredients,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CocktailRecipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      difficulty: difficulty ?? this.difficulty,
      preparationTimeMinutes: preparationTimeMinutes ?? this.preparationTimeMinutes,
      ingredients: ingredients ?? this.ingredients,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CocktailRecipe &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.instructions == instructions &&
        other.imageUrl == imageUrl &&
        other.difficulty == difficulty &&
        other.preparationTimeMinutes == preparationTimeMinutes &&
        other.ingredients == ingredients &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      instructions,
      imageUrl,
      difficulty,
      preparationTimeMinutes,
      ingredients,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'CocktailRecipe(id: $id, name: $name, difficulty: $difficulty, preparationTime: ${preparationTimeMinutes}min)';
  }
}

@immutable
final class CocktailIngredient {
  const CocktailIngredient({
    required this.id,
    required this.cocktailId,
    required this.name,
    required this.amount,
    required this.isOptional,
  });

  final int id;
  final int cocktailId;
  final String name;
  final String amount;
  final bool isOptional;

  CocktailIngredient copyWith({
    int? id,
    int? cocktailId,
    String? name,
    String? amount,
    bool? isOptional,
  }) {
    return CocktailIngredient(
      id: id ?? this.id,
      cocktailId: cocktailId ?? this.cocktailId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isOptional: isOptional ?? this.isOptional,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CocktailIngredient &&
        other.id == id &&
        other.cocktailId == cocktailId &&
        other.name == name &&
        other.amount == amount &&
        other.isOptional == isOptional;
  }

  @override
  int get hashCode {
    return Object.hash(id, cocktailId, name, amount, isOptional);
  }

  @override
  String toString() {
    return 'CocktailIngredient(name: $name, amount: $amount, optional: $isOptional)';
  }
}

extension CocktailDifficultyX on CocktailDifficulty {
  String get displayName {
    switch (this) {
      case CocktailDifficulty.easy:
        return 'Easy';
      case CocktailDifficulty.medium:
        return 'Medium';
      case CocktailDifficulty.hard:
        return 'Hard';
    }
  }
}
