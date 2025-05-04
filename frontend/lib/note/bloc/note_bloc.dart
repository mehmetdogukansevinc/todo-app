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
  }

  Future<void> _onFetchNotes(FetchNotes event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      final notes = await noteRepository.fetchNotes();
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError('Notlar getirilemedi: ${e.toString()}'));
    }
  }

  Future<void> _onCreateNote(
    CreateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(NoteLoading());
    try {
      await noteRepository.createNote(event.note);
      final notes = await noteRepository.fetchNotes();
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError('Not oluşturulamadı: ${e.toString()}'));
    }
  }
}
