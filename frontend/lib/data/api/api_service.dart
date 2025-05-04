import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../../note/models/note_model.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:3000/api',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );
    _setupTokenInterceptor();
  }

  void _setupTokenInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = Hive.box('authBox').get('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Response> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'username': username, 'email': email, 'password': password},
      );
      return response;
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response;
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<Response> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return response;
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<List<dynamic>> getNotes(String token) async {
    try {
      final response = await _dio.get(
        '/notes',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data == null || response.data['data'] == null) {
        print('API response error: ${response.data}');
        return [];
      }

      return response.data['data'];
    } on DioException catch (e) {
      print('API error getting notes: ${e.message}');
      // Hata durumunda boş liste döndür
      return [];
    } catch (e) {
      print('Unexpected error getting notes: $e');
      return [];
    }
  }

  Future<dynamic> createNote(String token, Note note) async {
    try {
      final response = await _dio.post(
        '/notes',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'title': note.title, 'content': note.content},
      );

      if (response.data == null || response.data['data'] == null) {
        throw Exception('API response is null or missing data');
      }

      return response.data['data'];
    } catch (e) {
      print('API error creating note: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(String token, String noteId) async {
    try {
      await _dio.delete(
        '/notes/$noteId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      print('API error deleting note: $e');
      rethrow;
    }
  }
}
