import 'package:cinemapedia/config/constants/environments.dart';
import 'package:cinemapedia/domain/datasources/actors_datasource.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/infrastructure/mappers/actor_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/credits_response.dart';
import 'package:dio/dio.dart';

class ActorMoviedbDataSource extends ActorsDatasource {
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
  Future<List<Actor>> getActorsByMovie(String movieId) async {
    final response = await dio.get('/movie/$movieId/credits');

    final castResponse = CreditsResponse.fromJson(response.data);

    final List<Actor> actors =
        castResponse.cast
            .map((element) => ActorMapper.castToEntity(element))
            .toList();
    return actors;
  }
}
