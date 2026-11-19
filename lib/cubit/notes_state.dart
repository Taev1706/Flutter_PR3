part of 'notes_cubit.dart';

@immutable
class Note {
  final int id;
  final String text;
  final bool isImportant;

  const Note({required this.id, required this.text, this.isImportant = false});

  Note copyWith({String? text, bool? isImportant}) {
    return Note(
      id: id,
      text: text ?? this.text,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}

@immutable
sealed class NotesState {
  final List<Note> notes;
  final int editingIndex;

  NotesState({required List<Note> notes, required this.editingIndex})
    : notes = List<Note>.unmodifiable(notes);
}

class NotesInitial extends NotesState {
  NotesInitial() : super(notes: [], editingIndex: -1);
}

class NotesUpdated extends NotesState {
  NotesUpdated({required List<Note> notes, required int editingIndex})
    : super(notes: notes, editingIndex: editingIndex);
}
