import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shaker_master/src/feature/cocktail/bloc/cocktail_bloc.dart';
import 'package:shaker_master/src/feature/cocktail/widget/cocktail_list_screen.dart';
import 'package:shaker_master/src/feature/initialization/widget/dependencies_scope.dart';

/// {@template home_screen}
/// HomeScreen displays the main cocktail list.
/// {@endtemplate}
class HomeScreen extends StatefulWidget {
  /// {@macro home_screen}
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final _logger = DependenciesScope.of(context).logger;

  @override
  void initState() {
    super.initState();
    _logger.info('Welcome To Shaker Master!');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CocktailBloc(DependenciesScope.of(context).cocktailRepository),
      child: const CocktailListScreen(),
    );
  }
}
