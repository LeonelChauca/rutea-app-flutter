import 'package:ruteaflutter/models/login_request.dart';

import '../api.dart';

class AuthService {
  Future<void> login(LoginRequest loginReq) async {
    final res = await Api.dio.post('/login', data: loginReq.toJson());
    print(res);
    return res.data;
  }
}
