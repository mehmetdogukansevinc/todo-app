part of 'note_bloc.dart';

abstract class NoteEvent {}

class FetchNotes extends NoteEvent {}

class CreateNoteEvent extends NoteEvent {
  final String title;
  final String content;

  CreateNoteEvent({required this.title, required this.content});
}
