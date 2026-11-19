import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/notes_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotesCubit(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NotesPage(),
      ),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _saveNote() {
    final String text = _controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    context.read<NotesCubit>().saveNote(text);
    _controller.clear();
    _focusNode.unfocus();
  }

  void _showNote(Note note) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(note.isImportant ? '⭐ Важная заметка' : 'Заметка'),
          content: SingleChildScrollView(child: SelectableText(note.text)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  void _editNote(Note note) {
    context.read<NotesCubit>().editNote(note.id);

    _controller.value = TextEditingValue(
      text: note.text,
      selection: TextSelection.collapsed(offset: note.text.length),
    );

    _focusNode.requestFocus();
  }

  void _deleteNote(int id) {
    final NotesCubit cubit = context.read<NotesCubit>();

    final int index = cubit.state.notes.indexWhere((note) => note.id == id);

    if (index == -1) {
      return;
    }

    if (cubit.state.editingIndex == index) {
      _controller.clear();
      _focusNode.unfocus();
    }

    cubit.deleteNote(id);
  }

  Widget _swipeBackground({
    required Color color,
    required IconData icon,
    required String text,
    required bool alignRight,
  }) {
    return Container(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Заметки'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/LLL.png'),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.paddingOf(context).top + kToolbarHeight + 16,
              16,
              16,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: state.editingIndex == -1
                        ? 'Введите заметку'
                        : 'Редактирование заметки',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF303030),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    state.editingIndex == -1
                        ? 'Сохранить'
                        : 'Сохранить изменения',
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.notes.length,
                    itemBuilder: (context, index) {
                      final Note note = state.notes[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Dismissible(
                          key: ValueKey(note.id),
                          direction: DismissDirection.horizontal,

                          background: _swipeBackground(
                            color: Colors.blueGrey,
                            icon: Icons.star_border,
                            text: 'Обычная заметка',
                            alignRight: false,
                          ),

                          secondaryBackground: _swipeBackground(
                            color: Colors.red,
                            icon: Icons.delete,
                            text: 'Удалить',
                            alignRight: true,
                          ),

                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              context.read<NotesCubit>().setNoteImportant(
                                note.id,
                                false,
                              );

                              return false;
                            }

                            return true;
                          },

                          onDismissed: (_) => _deleteNote(note.id),

                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,

                            onTap: () => _showNote(note),

                            onDoubleTap: () {
                              context.read<NotesCubit>().setNoteImportant(
                                note.id,
                                true,
                              );
                            },

                            onLongPress: () => _editNote(note),

                            child: Container(
                              decoration: BoxDecoration(
                                color: note.isImportant
                                    ? const Color(0xFF66501C)
                                    : const Color(0xFF303030),
                                border: Border.all(
                                  color: note.isImportant
                                      ? Colors.amber
                                      : Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                textColor: Colors.white,
                                leading: note.isImportant
                                    ? const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      )
                                    : null,
                                title: Text(
                                  note.text,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      color: Colors.white70,
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editNote(note),
                                    ),
                                    IconButton(
                                      color: Colors.white70,
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteNote(note.id),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
