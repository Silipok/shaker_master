import 'package:app_database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:shaker_master/src/feature/cocktail/model/cocktail_recipe.dart';

class CocktailCard extends StatelessWidget {
  const CocktailCard({required this.cocktail, required this.onTap, super.key});

  final CocktailRecipe cocktail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cocktail.name,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (cocktail.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            cocktail.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (cocktail.imageUrl != null) ...[
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        cocktail.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.local_bar, color: colorScheme.onSurfaceVariant),
                            ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildChip(
                    context,
                    icon: Icons.schedule,
                    label: '${cocktail.preparationTimeMinutes} min',
                  ),
                  _buildChip(
                    context,
                    icon: _getDifficultyIcon(cocktail.difficulty),
                    label: cocktail.difficulty.displayName,
                    color: _getDifficultyColor(context, cocktail.difficulty),
                  ),
                  _buildChip(
                    context,
                    icon: Icons.format_list_bulleted,
                    label: '${cocktail.ingredients.length} ingredients',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: effectiveColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDifficultyIcon(CocktailDifficulty difficulty) {
    return switch (difficulty) {
      CocktailDifficulty.easy => Icons.sentiment_satisfied,
      CocktailDifficulty.medium => Icons.sentiment_neutral,
      CocktailDifficulty.hard => Icons.sentiment_very_dissatisfied,
    };
  }

  Color _getDifficultyColor(BuildContext context, CocktailDifficulty difficulty) {
    return switch (difficulty) {
      CocktailDifficulty.easy => Colors.green,
      CocktailDifficulty.medium => Colors.orange,
      CocktailDifficulty.hard => Colors.red,
    };
  }
}
