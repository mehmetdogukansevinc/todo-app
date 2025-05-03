import 'package:dio/dio.dart';

import '../data/api/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<String> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await _apiService.register(username, email, password);
      return response.data['token'];
    } catch (e) {
      print(e.toString());
      throw Exception('Kayıt işlemi başarısız: ${e.toString()}');
    }
  }

  Future<String> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      return response.data['token'];
    } catch (e) {
      print(e.toString());
      throw Exception('Giriş işlemi başarısız: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      print(e.toString());
      throw Exception('Çıkış işlemi başarısız: ${e.toString()}');
    }
  }
}
