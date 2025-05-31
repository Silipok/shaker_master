import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shaker_master/src/feature/cocktail/bloc/cocktail_event.dart';
import 'package:shaker_master/src/feature/cocktail/bloc/cocktail_state.dart';
import 'package:shaker_master/src/feature/cocktail/data/cocktail_repository.dart';

final class CocktailBloc extends Bloc<CocktailEvent, CocktailState> {
  CocktailBloc(this._repository) : super(const CocktailInitial()) {
    on<CocktailLoadRequested>(_onLoadRequested);
    on<CocktailLoadMoreRequested>(_onLoadMoreRequested);
    on<CocktailSearchRequested>(_onSearchRequested);
    on<CocktailCreateRequested>(_onCreate);
    on<CocktailUpdateRequested>(_onUpdate);
    on<CocktailDeleteRequested>(_onDelete);
    on<CocktailRefreshRequested>(_onRefresh);
  }

  final CocktailRepository _repository;
  static const int _pageSize = 20;

  Future<void> _onLoadRequested(CocktailLoadRequested event, Emitter<CocktailState> emit) async {
    emit(const CocktailLoading());
    try {
      final cocktails = await _repository.getCocktails(searchQuery: event.searchQuery);
      final totalCount = await _repository.getCocktailCount(searchQuery: event.searchQuery);

      emit(
        CocktailLoaded(
          cocktails: cocktails,
          hasReachedMax: cocktails.length < _pageSize,
          totalCount: totalCount,
          searchQuery: event.searchQuery,
        ),
      );
    } catch (error) {
      emit(CocktailError(error.toString()));
    }
  }

  Future<void> _onLoadMoreRequested(
    CocktailLoadMoreRequested event,
    Emitter<CocktailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CocktailLoaded || currentState.hasReachedMax) return;

    emit(
      CocktailLoadingMore(
        cocktails: currentState.cocktails,
        totalCount: currentState.totalCount,
        searchQuery: currentState.searchQuery,
      ),
    );

    try {
      final newCocktails = await _repository.getCocktails(
        offset: currentState.cocktails.length,
        searchQuery: currentState.searchQuery,
      );

      emit(
        CocktailLoaded(
          cocktails: [...currentState.cocktails, ...newCocktails],
          hasReachedMax: newCocktails.length < _pageSize,
          totalCount: currentState.totalCount,
          searchQuery: currentState.searchQuery,
        ),
      );
    } catch (error) {
      emit(CocktailError(error.toString()));
    }
  }

  Future<void> _onSearchRequested(
    CocktailSearchRequested event,
    Emitter<CocktailState> emit,
  ) async {
    emit(const CocktailLoading());
    try {
      final cocktails = await _repository.getCocktails(
        searchQuery: event.query.isEmpty ? null : event.query,
      );
      final totalCount = await _repository.getCocktailCount(
        searchQuery: event.query.isEmpty ? null : event.query,
      );

      emit(
        CocktailLoaded(
          cocktails: cocktails,
          hasReachedMax: cocktails.length < _pageSize,
          totalCount: totalCount,
          searchQuery: event.query.isEmpty ? null : event.query,
        ),
      );
    } catch (error) {
      emit(CocktailError(error.toString()));
    }
  }

  Future<void> _onCreate(CocktailCreateRequested event, Emitter<CocktailState> emit) async {
    try {
      await _repository.createCocktail(event.cocktail);
      add(const CocktailRefreshRequested());
    } catch (error) {
      emit(CocktailError(error.toString()));
    }
  }

  Future<void> _onUpdate(CocktailUpdateRequested event, Emitter<CocktailState> emit) async {
    try {
      await _repository.updateCocktail(event.cocktail);
      add(const CocktailRefreshRequested());
    } catch (error) {
      emit(CocktailError(error.toString()));
    }
  }

  Future<void> _onDelete(CocktailDeleteRequested event, Emitter<CocktailState> emit) async {
    try {
      await _repository.deleteCocktail(event.id);
      add(const CocktailRefreshRequested());
    } catch (error) {
      emit(CocktailError(error.toString()));
    }
  }

  Future<void> _onRefresh(CocktailRefreshRequested event, Emitter<CocktailState> emit) async {
    final currentState = state;
    final searchQuery = currentState is CocktailLoaded ? currentState.searchQuery : null;

    add(CocktailLoadRequested(searchQuery: searchQuery));
  }
}
