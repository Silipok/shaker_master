import 'package:flutter/material.dart';
import 'package:shaker_master/src/feature/cocktail/model/cocktail_recipe.dart';
import 'package:shaker_master/src/feature/initialization/widget/dependencies_scope.dart';

class CocktailDetailScreen extends StatefulWidget {
  const CocktailDetailScreen({required this.cocktailId, super.key});

  final int cocktailId;

  @override
  State<CocktailDetailScreen> createState() => _CocktailDetailScreenState();
}

class _CocktailDetailScreenState extends State<CocktailDetailScreen> {
  CocktailRecipe? cocktail;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCocktail();
  }

  Future<void> _loadCocktail() async {
    try {
      final repository = DependenciesScope.of(context).cocktailRepository;
      final result = await repository.getCocktailById(widget.cocktailId);
      setState(() {
        cocktail = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    error = null;
                  });
                  _loadCocktail();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (cocktail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Cocktail not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(cocktail!.name),
              background:
                  cocktail!.imageUrl != null
                      ? Image.network(
                        cocktail!.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => ColoredBox(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.local_bar,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                      )
                      : ColoredBox(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.local_bar,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (cocktail!.description != null) ...[
                  Text(cocktail!.description!, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                ],
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Details', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 16),
                            const SizedBox(width: 8),
                            Text('${cocktail!.preparationTimeMinutes} minutes'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.bar_chart, size: 16),
                            const SizedBox(width: 8),
                            Text('Difficulty: ${cocktail!.difficulty.displayName}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        ...cocktail!.ingredients.map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color:
                                        ingredient.isOptional
                                            ? Colors.orange
                                            : Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${ingredient.amount} ${ingredient.name}',
                                    style:
                                        ingredient.isOptional
                                            ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontStyle: FontStyle.italic,
                                            )
                                            : Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                if (ingredient.isOptional)
                                  Text(
                                    'optional',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.orange,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Text(cocktail!.instructions, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
