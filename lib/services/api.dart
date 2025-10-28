// api.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ruteaflutter/core/interceptors/auth_interceptor.dart';
import 'package:ruteaflutter/core/storage/token_storage.dart';
import 'package:ruteaflutter/services/auth/auth.service.dart'; // ajusta ruta

class Api {
  static late final Dio dio;
  static bool _initialized = false;

  static void initializeInterceptors(TokenStorage storage) {
    if (_initialized) return;

    final baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    dio = Dio(
      BaseOptions(
        responseType: ResponseType.json,
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    final auth = AuthService(dio, storage);

    dio.interceptors.add(
      AuthInterceptor(dio: dio, tokenStorage: storage, auth: auth),
    );

    assert(() {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
      return true;
    }());

    _initialized = true;
  }
}
