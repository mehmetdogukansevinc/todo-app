part of 'note_bloc.dart';

abstract class NoteEvent {}

class FetchNotes extends NoteEvent {}

class CreateNoteEvent extends NoteEvent {
  final Note note;

  CreateNoteEvent({required this.note});
}
