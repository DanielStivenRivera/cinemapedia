import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemapedia/presentation/views/movies/home_view.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

import '../../views/home_views/favorites_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  final viewRoutes = const <Widget>[HomeView(), SizedBox(), FavoritesView()];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isMovieDetailScreen = location.contains('/movie/');
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar:
          !isMovieDetailScreen
              ? CustomBottomNavigation(navigationShell: navigationShell)
              : null,
    );
  }
}
