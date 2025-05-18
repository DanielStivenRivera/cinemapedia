import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environments {
  static String movieDbToken = dotenv.env['THE_MOVIE_DB_TOKEN'] ?? '';
  static String movieDbKey = dotenv.env['THE_MOVIE_DB_KEY'] ?? 'No Api Key';
}
