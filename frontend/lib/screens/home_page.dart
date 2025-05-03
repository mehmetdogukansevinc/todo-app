import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/auth_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../note/bloc/note_bloc.dart';
import '../note/models/note_model.dart';
import 'login_register_page.dart';

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

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final Note note = notes[index];
                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.content),
                  trailing: Icon(
                    note.completed ? Icons.check : Icons.close,
                    color: note.completed ? Colors.green : Colors.red,
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Hoş geldin!'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<NoteBloc>().add(FetchNotes());
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
