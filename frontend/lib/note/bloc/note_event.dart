part of 'note_bloc.dart';

abstract class NoteEvent {}

class FetchNotes extends NoteEvent {}

class CreateNoteEvent extends NoteEvent {
  final Note note;

  CreateNoteEvent({required this.note});
}

class DeleteNoteEvent extends NoteEvent {
  final String noteId;

  DeleteNoteEvent({required this.noteId});
}
