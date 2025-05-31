import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shaker_master/src/feature/cocktail/bloc/cocktail_bloc.dart';
import 'package:shaker_master/src/feature/cocktail/bloc/cocktail_event.dart';
import 'package:shaker_master/src/feature/cocktail/bloc/cocktail_state.dart';
import 'package:shaker_master/src/feature/cocktail/widget/add_cocktail_screen.dart';
import 'package:shaker_master/src/feature/cocktail/widget/cocktail_card.dart';
import 'package:shaker_master/src/feature/cocktail/widget/cocktail_detail_screen.dart';

class CocktailListScreen extends StatefulWidget {
  const CocktailListScreen({super.key});

  @override
  State<CocktailListScreen> createState() => _CocktailListScreenState();
}

class _CocktailListScreenState extends State<CocktailListScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _scrollController.addListener(_onScroll);
    context.read<CocktailBloc>().add(const CocktailLoadRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<CocktailBloc>().add(const CocktailLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearch(String query) {
    context.read<CocktailBloc>().add(CocktailSearchRequested(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            title: const Text('Cocktail Recipes'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _navigateToAddCocktail(context),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search cocktails...',
                  onChanged: _onSearch,
                  leading: const Icon(Icons.search),
                  trailing: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          BlocBuilder<CocktailBloc, CocktailState>(
            builder: (context, state) {
              return switch (state) {
                CocktailLoading() => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                CocktailError(:final message) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $message',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed:
                              () => context.read<CocktailBloc>().add(
                                const CocktailRefreshRequested(),
                              ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                CocktailLoaded(:final cocktails, :final totalCount) ||
                CocktailLoadingMore(:final cocktails, :final totalCount) =>
                  cocktails.isEmpty
                      ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_bar_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No cocktails found',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first cocktail recipe!',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () => _navigateToAddCocktail(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Cocktail'),
                              ),
                            ],
                          ),
                        ),
                      )
                      : SliverList.separated(
                        itemCount: cocktails.length + (state is CocktailLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= cocktails.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final cocktail = cocktails[index];
                          return CocktailCard(
                            cocktail: cocktail,
                            onTap: () => _navigateToDetail(context, cocktail.id),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                      ),
                _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
              };
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }

  void _navigateToAddCocktail(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => const AddCocktailScreen()));
  }

  void _navigateToDetail(BuildContext context, int cocktailId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => CocktailDetailScreen(cocktailId: cocktailId)),
    );
  }
}
