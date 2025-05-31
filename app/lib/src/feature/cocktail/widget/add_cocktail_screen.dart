import 'package:app_database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shaker_master/src/feature/cocktail/bloc/cocktail_bloc.dart';
import 'package:shaker_master/src/feature/cocktail/bloc/cocktail_event.dart';
import 'package:shaker_master/src/feature/cocktail/model/cocktail_recipe.dart';

class AddCocktailScreen extends StatefulWidget {
  const AddCocktailScreen({super.key});

  @override
  State<AddCocktailScreen> createState() => _AddCocktailScreenState();
}

class _AddCocktailScreenState extends State<AddCocktailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _preparationTimeController = TextEditingController();

  CocktailDifficulty _difficulty = CocktailDifficulty.easy;
  final List<_IngredientInput> _ingredients = [_IngredientInput()];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _imageUrlController.dispose();
    _preparationTimeController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(_IngredientInput());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredients.length > 1) {
      setState(() {
        _ingredients.removeAt(index);
      });
    }
  }

  void _saveCocktail() {
    if (_formKey.currentState!.validate()) {
      final ingredients =
          _ingredients
              .where((i) => i.nameController.text.isNotEmpty)
              .map(
                (i) => CocktailIngredient(
                  id: 0,
                  cocktailId: 0,
                  name: i.nameController.text,
                  amount: i.amountController.text,
                  isOptional: i.isOptional,
                ),
              )
              .toList();

      if (ingredients.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please add at least one ingredient')));
        return;
      }

      final cocktail = CocktailRecipe(
        id: 0,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        instructions: _instructionsController.text,
        imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
        difficulty: _difficulty,
        preparationTimeMinutes: int.parse(_preparationTimeController.text),
        ingredients: ingredients,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<CocktailBloc>().add(CocktailCreateRequested(cocktail));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Cocktail'),
        actions: [TextButton(onPressed: _saveCocktail, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Cocktail Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a cocktail name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _preparationTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Prep Time (minutes)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter prep time';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<CocktailDifficulty>(
                    value: _difficulty,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        CocktailDifficulty.values.map((difficulty) {
                          return DropdownMenuItem(
                            value: difficulty,
                            child: Text(difficulty.displayName),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _difficulty = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ..._ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ingredient = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: ingredient.nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Ingredient Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: ingredient.amountController,
                                decoration: const InputDecoration(
                                  labelText: 'Amount',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeIngredient(index),
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          title: const Text('Optional ingredient'),
                          value: ingredient.isOptional,
                          onChanged: (value) {
                            setState(() {
                              ingredient.isOptional = value!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            FilledButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add),
              label: const Text('Add Ingredient'),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter instructions';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientInput {
  _IngredientInput() {
    nameController = TextEditingController();
    amountController = TextEditingController();
  }

  late final TextEditingController nameController;
  late final TextEditingController amountController;
  bool isOptional = false;
}
