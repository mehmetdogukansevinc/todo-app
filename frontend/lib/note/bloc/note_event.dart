part of 'note_bloc.dart';

abstract class NoteEvent {}

class FetchNotes extends NoteEvent {}

class CreateNoteEvent extends NoteEvent {
  final Note note;

  CreateNoteEvent({required this.note});
}

class UpdateNoteEvent extends NoteEvent {
  final String noteId;
  final Note updatedNote;

  UpdateNoteEvent({required this.noteId, required this.updatedNote});
}

class DeleteNoteEvent extends NoteEvent {
  final String noteId;

  DeleteNoteEvent({required this.noteId});
}
