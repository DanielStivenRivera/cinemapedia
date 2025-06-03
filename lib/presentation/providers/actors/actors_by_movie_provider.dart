import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/presentation/providers/actors/actors_repository_provider.dart';

final actorsByMovieProvider = StateNotifierProvider<
  ActorsByMovieNotifier,
  Map<String, List<Actor>>
>((ref) {
  final actorsRepository = ref.watch(actorsRepositoryProvider).getActorsByMovie;
  return ActorsByMovieNotifier(getActors: actorsRepository);
});

typedef GetActorsCallback = Future<List<Actor>> Function(String movieId);

class ActorsByMovieNotifier extends StateNotifier<Map<String, List<Actor>>> {
  ActorsByMovieNotifier({required this.getActors}) : super({});
  final GetActorsCallback getActors;

  Future<void> loadActors(String movieId) async {
    if (state[movieId] != null) return;
    final actors = await getActors(movieId.toString());
    state = {...state, movieId: actors};
  }
}
