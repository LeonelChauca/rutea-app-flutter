import 'package:dio/dio.dart';
import 'package:ruteaflutter/core/storage/token_storage.dart';
import 'package:ruteaflutter/services/auth/auth.service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage tokenStorage;
  final AuthService auth;

  bool _isRefreshing = false;

  AuthInterceptor({
    required this.dio,
    required this.tokenStorage,
    required this.auth,
  });

  bool _isRefreshCall(RequestOptions req) =>
      req.path.endsWith('/auth/refresh_token');

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isRefreshCall(options)) {
      final access = await tokenStorage.readAccess();
      if (access != null && access.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $access';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode ?? 0;

    if (status != 401 ||
        err.requestOptions.extra['__retried__'] == true ||
        _isRefreshCall(err.requestOptions)) {
      return handler.next(err);
    }

    final refresh = await tokenStorage.readRefresh();
    final access = await tokenStorage.readAccess();
    if (refresh == null || access == null) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;
    try {
      final res = await auth.refreshToken();
      final newAccess = res['accessToken'] as String;
      final newRefresh = (res['refreshToken']) ?? refresh;
      await tokenStorage.saveTokens(newAccess, newRefresh);

      _isRefreshing = false;

      final req = err.requestOptions;
      req.headers['Authorization'] = 'Bearer $newAccess';
      req.extra = {...req.extra, '__retried__': true};

      final response = await dio.fetch(req);
      return handler.resolve(response);
    } catch (e) {
      _isRefreshing = false;
      await tokenStorage.clear();
      return handler.next(err);
    }
  }
}
