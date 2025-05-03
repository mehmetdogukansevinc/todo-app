import '../data/api/api_service.dart';

class NoteRepository {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> fetchNotes(String token) async {
    return await _apiService.getNotes(token);
  }
}
