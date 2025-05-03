import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'bloc/auth_bloc.dart';
import 'note/bloc/note_bloc.dart';
import 'repository/auth_repo.dart';
import 'repository/note_repository.dart';
import 'screens/home_page.dart';
import 'screens/login_register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('authBox');

  final box = Hive.box('authBox');
  final token = box.get('token');

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthRepository())),
        BlocProvider(create: (_) => NoteBloc(NoteRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: isLoggedIn ? HomePage() : LoginRegisterPage(),
      ),
    );
  }
}
