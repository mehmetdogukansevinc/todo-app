import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../repository/note_repository.dart';
import '../models/note_model.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository noteRepository;

  NoteBloc(this.noteRepository) : super(NoteInitial()) {
    on<FetchNotes>(_onFetchNotes);
    on<CreateNoteEvent>(_onCreateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
  }

  Future<void> _onFetchNotes(FetchNotes event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      final notes = await noteRepository.fetchNotes();
      emit(NoteLoaded(notes));
    } catch (e) {
      print('Error fetching notes: $e');
      emit(NoteError('Notlar getirilemedi: ${e.toString()}'));
      // Hata sonrası boş liste ile yüklendi durumuna geç
      emit(NoteLoaded([]));
    }
  }

  Future<void> _onCreateNote(
    CreateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    // Mevcut durumu sakla
    final currentState = state;

    emit(NoteLoading());
    try {
      await noteRepository.createNote(event.note);
      final notes = await noteRepository.fetchNotes();
      emit(NoteLoaded(notes));
    } catch (e) {
      print('Error creating note: $e');
      emit(NoteError('Not oluşturulamadı: ${e.toString()}'));

      // Hata durumunda önceki duruma dön
      if (currentState is NoteLoaded) {
        emit(currentState);
      } else {
        // Önceki durum yüklü değilse boş liste döndür
        emit(NoteLoaded([]));
      }
    }
  }

  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    // Mevcut durumu saklayalım ki silme işlemi başarısız olursa geri dönelim
    final currentState = state;

    if (currentState is NoteLoaded) {
      try {
        // Önce UI güncelle, noteId olmayan edge case'lere karşı güvenlik kontrolü
        if (event.noteId.isEmpty) {
          emit(NoteError('Geçersiz not ID\'si'));
          return;
        }

        // Optimistik güncelleme - UI'dan hemen silelim
        final updatedNotes = List<Note>.from(currentState.notes)
          ..removeWhere((note) => note.id == event.noteId);

        emit(NoteLoaded(updatedNotes));

        // Backend'den silelim
        await noteRepository.deleteNote(event.noteId);
        // Eğer başarılı olursa zaten UI güncel durumda
      } catch (e) {
        print('Error deleting note: $e');
        // Eğer başarısız olursa, önceki duruma geri dönelim
        emit(NoteError('Not silinemedi: ${e.toString()}'));
        // Notları tekrar yükleyelim
        emit(currentState);
      }
    }
  }
}
