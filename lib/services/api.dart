import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Api {
  static Dio dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_URL'] ?? 'https://api.example.com',
      headers: {'Content-Type': 'application/json'},
    ),
  );
}
