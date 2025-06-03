import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';

typedef SearchMoviesCallback = Future<List<Movie>> Function(String query);

class SearchMovieDelegate extends SearchDelegate<Movie?> {
  SearchMovieDelegate(this.searchMovies, this.initialMovies);

  final SearchMoviesCallback searchMovies;
  List<Movie> initialMovies;

  StreamController<List<Movie>> debouncedMovies = StreamController.broadcast();
  StreamController<bool> isLoadingStream = StreamController.broadcast();

  Timer? _debounceTimer;

  void _onQueryChange(String query) {
    isLoadingStream.add(true);
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final movies = await searchMovies(query);
      initialMovies = movies;
      debouncedMovies.add(movies);
      isLoadingStream.add(false);
    });
  }

  void clearStreams() {
    _debounceTimer?.cancel();
    if (debouncedMovies.isClosed) return;
    debouncedMovies.close();
  }

  @override
  String get searchFieldLabel => 'Buscar películas';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      StreamBuilder<bool>(
        stream: isLoadingStream.stream,
        initialData: false,
        builder: (ctx, snapshot) {
          if (snapshot.data ?? false) {
            return SpinPerfect(
              duration: const Duration(seconds: 1),
              spins: 10,
              infinite: true,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.refresh_outlined),
              ),
            );
          }
          return FadeIn(
            animate: query.isNotEmpty,
            duration: const Duration(milliseconds: 100),
            child: IconButton(
              onPressed: () => query = '',
              icon: const Icon(Icons.clear_outlined),
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        clearStreams();
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back_ios_outlined),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildScreen();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChange(query);
    return buildScreen();
  }

  Widget buildScreen() {
    if (query.isEmpty) {
      return const Center(
        child: Text('Escribe el nombre de una película para buscar.'),
      );
    }

    return StreamBuilder<List<Movie>>(
      // future: _searchMovies(query),
      stream: debouncedMovies.stream,
      initialData: initialMovies,
      builder: (ctx, snapshot) {
        final List<Movie> movies = snapshot.data ?? [];

        return ListView.builder(
          itemBuilder:
              (ctx, index) => _MovieItem(
                movie: movies[index],
                onMovieSelected: (context, movie) {
                  clearStreams();
                  close(context, movie);
                },
              ),
          itemCount: movies.length,
        );
      },
    );
  }
}

typedef MovieSelectedCallBack =
    void Function(BuildContext context, Movie? movie);

class _MovieItem extends StatelessWidget {
  const _MovieItem({required this.movie, required this.onMovieSelected});
  final Movie movie;
  final MovieSelectedCallBack onMovieSelected;

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onMovieSelected(context, movie);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: size.width * 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.posterPath,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, loadingProgress) {
                    if (loadingProgress == null) return FadeIn(child: child);
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: textStyles.titleLarge),
                  const SizedBox(height: 5),
                  Text(
                    movie.overview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.star_half_rounded,
                        color: Colors.yellow.shade800,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        HumanFormats.number(movie.voteAverage, decimals: 1),
                        style: textStyles.bodyMedium!.copyWith(
                          color: Colors.yellow.shade900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
