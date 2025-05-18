import 'package:cinemapedia/config/constants/environments.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/mappers/movie_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/movie_db_response.dart';
import 'package:dio/dio.dart';

class MovieDBDataSource extends MoviesDataSource {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {
        'api_key': Environments.movieDbKey,
        'language': 'es-MX',
      },
      headers: {'Authorization': 'Bearer ${Environments.movieDbToken}'},
    ),
  );
  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final response = await dio.get('/movie/now_playing');
    final movieDbResponse = MovieDbResponse.fromJson(response.data);
    final List<Movie> movies =
        movieDbResponse.results
            .where((e) => e.posterPath != 'no-poster')
            .map((e) => MovieMapper.movieDbToEntity(e))
            .toList();
    return movies;
  }
}
