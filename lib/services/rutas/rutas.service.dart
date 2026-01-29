import 'package:dio/dio.dart';
import 'package:ruteaflutter/features/create-lineas/models/linea_trasport_model.dart';
import 'package:ruteaflutter/services/api.dart';

class RutasService {
  final Dio dio;

  RutasService(this.dio);
  Future<Map<String, dynamic>> registerRuta(
    RegistroLineaCompleto registro,
  ) async {
    try {
      final res = await Api.dio.post(
        '/rutas/rutas_general',
        data: registro.toJson(),
      );

      final data = res.data;
      if (data is Map<String, dynamic>) {
        return data;
      }

      return {'data': data};
    } on DioException catch (e) {
      String message = 'Ocurrió un error al registrar la ruta';

      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic> &&
          responseData['message'] != null) {
        message = responseData['message'].toString();
      }

      throw Exception(message);
    } catch (_) {
      throw Exception('Ocurrió un error al registrar la ruta');
    }
  }
}