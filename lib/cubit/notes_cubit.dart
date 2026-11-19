import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial());

  int _nextId = 0;

  void saveNote(String value) {
    final String text = value.trim();

    if (text.isEmpty) {
      return;
    }

    final List<Note> notes = List<Note>.from(state.notes);

    if (state.editingIndex == -1) {
      notes.add(Note(id: _nextId++, text: text));
    } else {
      final int index = state.editingIndex;

      notes[index] = notes[index].copyWith(text: text);
    }

    emit(NotesUpdated(notes: notes, editingIndex: -1));
  }

  void editNote(int id) {
    final int index = state.notes.indexWhere((note) => note.id == id);

    if (index == -1) {
      return;
    }

    emit(NotesUpdated(notes: state.notes, editingIndex: index));
  }

  void deleteNote(int id) {
    final int index = state.notes.indexWhere((note) => note.id == id);

    if (index == -1) {
      return;
    }

    final List<Note> notes = List<Note>.from(state.notes);
    int editingIndex = state.editingIndex;

    notes.removeAt(index);

    if (editingIndex == index) {
      editingIndex = -1;
    } else if (editingIndex > index) {
      editingIndex--;
    }

    emit(NotesUpdated(notes: notes, editingIndex: editingIndex));
  }

  void setNoteImportant(int id, bool isImportant) {
    final int index = state.notes.indexWhere((note) => note.id == id);

    if (index == -1 || state.notes[index].isImportant == isImportant) {
      return;
    }

    final List<Note> notes = List<Note>.from(state.notes);

    notes[index] = notes[index].copyWith(isImportant: isImportant);

    emit(NotesUpdated(notes: notes, editingIndex: state.editingIndex));
  }
}
