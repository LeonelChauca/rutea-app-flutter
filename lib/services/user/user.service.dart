import 'package:dio/dio.dart';
import 'package:ruteaflutter/models/register_request.dart';
import 'package:ruteaflutter/services/api.dart';

class UserService {
  final Dio dio;
  UserService(this.dio);
  Future<dynamic> register(RegisterRequest registerReq) async {
    try {
      final res = await Api.dio.post(
        '/usuario/register',
        data: registerReq.toJson(),
      );

      print('Register response: ${res.data}');
      return res.data;
    } catch (e) {
      if (e is DioException) {
        // Manejo de errores de la API
        if (e.response != null) {
          throw e.response?.data['detail'];
        }
      }
      rethrow;
    }
  }
}
