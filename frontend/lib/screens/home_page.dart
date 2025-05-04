import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/auth_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../note/bloc/note_bloc.dart';
import '../note/models/note_model.dart';
import 'create_note_page.dart';
import 'login_register_page.dart';
import 'update_note_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Notları sayfa yüklendiğinde otomatik olarak getir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteBloc>().add(FetchNotes());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notlarım'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginRegisterPage()),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocConsumer<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is NoteLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is NoteLoaded) {
            final notes = state.notes;

            if (notes.isEmpty) {
              return Center(child: Text('Henüz not bulunmuyor.'));
            }

            // Debug - not ID'lerini kontrol et
            for (var note in notes) {
              print('Loaded note ID: ${note.id}, Title: ${note.title}');
            }

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final Note note = notes[index];

                // Not ID kontrolü
                if (note.id.isEmpty) {
                  return ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.content),
                    trailing: Icon(
                      note.completed ? Icons.check : Icons.close,
                      color: note.completed ? Colors.green : Colors.red,
                    ),
                  );
                }

                return Dismissible(
                  key: Key(note.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) {
                    return showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Notu Sil'),
                            content: Text(
                              'Bu notu silmek istediğinize emin misiniz?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: Text('İptal'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: Text('Sil'),
                              ),
                            ],
                          ),
                    );
                  },
                  onDismissed: (direction) {
                    // Not silindi, Bloc'a bildir
                    print('Deleting note with ID: ${note.id}');
                    context.read<NoteBloc>().add(
                      DeleteNoteEvent(noteId: note.id),
                    );
                  },
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.content),
                    trailing: Icon(
                      note.completed ? Icons.check : Icons.close,
                      color: note.completed ? Colors.green : Colors.red,
                    ),
                    onTap: () {
                      // Not düzenleme sayfasına yönlendir
                      print('Opening edit screen for note ID: ${note.id}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateNotePage(note: note),
                        ),
                      ).then((_) {
                        // Sayfadan döndüğünde notları yenile
                        context.read<NoteBloc>().add(FetchNotes());
                      });
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Hoş geldin!'));
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'create',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateNotePage()),
              ).then((_) {
                // Sayfadan döndüğünde notları yenile
                context.read<NoteBloc>().add(FetchNotes());
              });
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: () {
              context.read<NoteBloc>().add(FetchNotes());
            },
            child: Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
