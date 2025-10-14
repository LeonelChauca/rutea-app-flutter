import 'package:dio/dio.dart';
import 'package:ruteaflutter/core/storage/token_storage.dart';
import 'package:ruteaflutter/models/login_request.dart';
import 'package:ruteaflutter/core/storage/user_storage.dart';
import '../api.dart';

class AuthService {
  final Dio dio;
  final TokenStorage token;
  final UserStorage userStorage = UserStorage();
  AuthService(this.dio, this.token);
  Future<void> login(LoginRequest loginReq) async {
    final res = await Api.dio.post('/auth/login', data: loginReq.toJson());
    final access = res.data['access_token'] as String;
    final refresh = res.data['refresh_token'] as String;
    await token.saveTokens(access, refresh);

    final user = Map<String, dynamic>.from(res.data['user']);
    await userStorage.saveUser(user);
    return res.data;
  }

  Future<Map<String, String>> refreshToken() async {
    final res = await Api.dio.post('/auth/refresh_token');
    return res.data;
  }
}
