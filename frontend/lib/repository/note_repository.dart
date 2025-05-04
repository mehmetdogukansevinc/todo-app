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

  Future<Note> createNote(Note note) async {
    final token = Hive.box('authBox').get('token');
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    final noteJson = await _apiService.createNote(token, note);
    return Note.fromJson(noteJson);
  }

  Future<Note> updateNote(String noteId, Note note) async {
    final token = Hive.box('authBox').get('token');
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    print('Repository updateNote - noteId: $noteId');
    print(
      'Repository updateNote - note content: ${note.title}, ${note.content}, ${note.completed}',
    );

    final noteJson = await _apiService.updateNote(token, noteId, note);
    return Note.fromJson(noteJson);
  }

  Future<void> deleteNote(String noteId) async {
    final token = Hive.box('authBox').get('token');
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    await _apiService.deleteNote(token, noteId);
  }
}
