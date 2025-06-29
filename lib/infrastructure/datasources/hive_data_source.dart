import 'package:hive/hive.dart';
import 'package:cinemapedia/domain/datasources/local_storage_data_source.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

class HiveDataSource extends LocalStorageDataSource {
  Box<Movie>? _movieBox;
  static const String _boxName = 'favorite_movies';

  Future<void> _ensureBoxOpen() async {
    if (_movieBox == null || !_movieBox!.isOpen) {
      _movieBox = await Hive.openBox<Movie>(_boxName);
    }
  }

  @override
  Future<bool> isMovieFavorite(int movieId) async {
    await _ensureBoxOpen();
    return _movieBox!.containsKey(movieId.toString());
  }

  @override
  Future<List<Movie>> loadMovies({int limit = 15, offset = 0}) async {
    await _ensureBoxOpen();

    final allMovies = _movieBox!.values.toList();

    final startIndex = offset;
    final endIndex = (startIndex + limit).clamp(0, allMovies.length);

    if (startIndex >= allMovies.length) {
      return [];
    }

    return allMovies.sublist(startIndex, endIndex);
  }

  @override
  Future<void> toggleFavorite(Movie movie) async {
    await _ensureBoxOpen();

    final movieId = movie.id.toString();
    if (_movieBox!.containsKey(movieId)) {
      await _movieBox!.delete(movieId);
    } else {
      await _movieBox!.put(movieId, movie);
    }
  }

  Future<void> close() async {
    await _movieBox?.close();
  }
}
