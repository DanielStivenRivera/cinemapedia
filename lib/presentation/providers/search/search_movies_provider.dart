import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

import '../providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchMoviesProvider =
    StateNotifierProvider<SearchMoviesNotifier, List<Movie>>((ref) {
      final searchMovies = ref.read(movieRepositoryProvider).searchMovies;
      return SearchMoviesNotifier(ref: ref, searchMovies: searchMovies);
    });

typedef SearchMoviesCallback = Future<List<Movie>> Function(String query);

class SearchMoviesNotifier extends StateNotifier<List<Movie>> {
  SearchMoviesNotifier({required this.searchMovies, required this.ref})
    : super([]);
  SearchMoviesCallback searchMovies;
  final Ref ref;

  Future<List<Movie>> searchMoviesByQuery(String query) async {
    ref.read(searchQueryProvider.notifier).update((state) => query);
    final List<Movie> movies = await searchMovies(query);
    state = movies;
    return movies;
  }
}
