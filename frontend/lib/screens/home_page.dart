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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    // Notları sayfa yüklendiğinde otomatik olarak getir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteBloc>().add(FetchNotes());
    });

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          'Notlarım',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginRegisterPage()),
              );
            },
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: BlocConsumer<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NoteLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          } else if (state is NoteLoaded) {
            final notes = state.notes;

            if (notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz not bulunmuyor.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yeni not eklemek için + butonuna tıklayın',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            // Debug - not ID'lerini kontrol et
            for (var note in notes) {
              print('Loaded note ID: ${note.id}, Title: ${note.title}');
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final Note note = notes[index];

                  // Not ID kontrolü
                  if (note.id.isEmpty) {
                    return _buildNoteCard(note, canDismiss: false);
                  }

                  return Dismissible(
                    key: Key(note.id),
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) {
                      return showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Notu Sil'),
                              content: const Text(
                                'Bu notu silmek istediğinize emin misiniz?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: Text(
                                    'İptal',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[400],
                                  ),
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text('Sil'),
                                ),
                              ],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                    child: _buildNoteCard(note),
                  );
                },
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_emotions,
                    size: 70,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hoş geldin!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'create',
            backgroundColor: theme.colorScheme.primary,
            elevation: 4,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateNotePage()),
              ).then((_) {
                // Sayfadan döndüğünde notları yenile
                context.read<NoteBloc>().add(FetchNotes());
              });
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'refresh',
            backgroundColor: theme.colorScheme.secondary,
            elevation: 4,
            onPressed: () {
              _fabAnimationController.reset();
              _fabAnimationController.forward();
              context.read<NoteBloc>().add(FetchNotes());
            },
            child: RotationTransition(
              turns: Tween(
                begin: 0.0,
                end: 1.0,
              ).animate(_fabAnimationController),
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note, {bool canDismiss = true}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        title: Text(
          note.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            note.content,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: note.completed ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            note.completed ? Icons.check : Icons.close,
            color: note.completed ? Colors.green[700] : Colors.red[700],
            size: 20,
          ),
        ),
        onTap:
            canDismiss
                ? () {
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
                }
                : null,
      ),
    );
  }
}
