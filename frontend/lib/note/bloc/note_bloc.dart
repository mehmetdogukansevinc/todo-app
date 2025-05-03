import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../../repository/note_repository.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository noteRepository;

  NoteBloc(this.noteRepository) : super(NoteInitial()) {
    on<FetchNotes>(_onFetchNotes);
  }

  Future<void> _onFetchNotes(FetchNotes event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      final token = Hive.box('authBox').get('token');
      final notes = await noteRepository.fetchNotes(token);
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError('Notlar getirilemedi: ${e.toString()}'));
    }
  }
}
