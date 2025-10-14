import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruteaflutter/core/storage/token_storage.dart';
import 'package:ruteaflutter/services/api.dart';
import 'package:ruteaflutter/services/auth/auth.service.dart';
import 'package:ruteaflutter/services/user/user.service.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.read(tokenStorageProvider);
  Api.initializeInterceptors(storage); // inicializas interceptores
  return Api.dio;
});

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.read(dioProvider);
  final storage = ref.read(tokenStorageProvider);
  return AuthService(dio, storage);
});

final userServiceProvider = Provider<UserService>((ref) {
  final dio = ref.read(dioProvider);
  return UserService(dio);
});
