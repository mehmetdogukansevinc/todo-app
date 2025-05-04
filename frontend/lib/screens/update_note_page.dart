import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../note/bloc/note_bloc.dart';
import '../note/models/note_model.dart';

class UpdateNotePage extends StatefulWidget {
  final Note note;

  const UpdateNotePage({Key? key, required this.note}) : super(key: key);

  @override
  _UpdateNotePageState createState() => _UpdateNotePageState();
}

class _UpdateNotePageState extends State<UpdateNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool _isCompleted;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _isCompleted = widget.note.completed;

    // Debug bilgisi
    print('Note to be updated: ${widget.note.id}');
    print(
      'Note content: ${widget.note.title}, ${widget.note.content}, ${widget.note.completed}',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Not modelini güncelleme için oluştur
      final updatedNote = Note(
        id: widget.note.id,
        title: _titleController.text,
        content: _contentController.text,
        userId: widget.note.userId,
        completed: _isCompleted,
        createdAt: widget.note.createdAt,
        updatedAt: DateTime.now(),
      );

      print('Sending update for noteId: ${widget.note.id}');
      print(
        'Updated note content: ${updatedNote.title}, ${updatedNote.content}, ${updatedNote.completed}',
      );

      context.read<NoteBloc>().add(
        UpdateNoteEvent(noteId: widget.note.id, updatedNote: updatedNote),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notu Düzenle')),
      body: BlocListener<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            setState(() {
              _isSubmitting = false;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Not ID: ${widget.note.id}',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Başlık',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir başlık girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'İçerik',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir içerik girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text('Tamamlandı'),
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value;
                    });
                  },
                  secondary: Icon(
                    _isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: _isCompleted ? Colors.green : Colors.grey,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isSubmitting
                          ? CircularProgressIndicator()
                          : Text('Notu Güncelle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
