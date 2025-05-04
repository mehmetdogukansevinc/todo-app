import '../data/api/api_service.dart';
import '../note/models/note_model.dart';
import 'package:hive/hive.dart';

class NoteRepository {
  final ApiService _apiService = ApiService();

  Future<List<Note>> fetchNotes() async {
    final token = Hive.box('authBox').get('token');
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    final notesJson = await _apiService.getNotes(token);

    // JSON listesini Note modellerine dönüştür
    return notesJson.map((noteJson) => Note.fromJson(noteJson)).toList();
  }

  Future<Note> createNote(String title, String content) async {
    final token = Hive.box('authBox').get('token');
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    final noteJson = await _apiService.createNote(token, title, content);
    return Note.fromJson(noteJson);
  }
}
