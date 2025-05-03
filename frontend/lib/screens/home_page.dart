import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_register_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Kullanıcı bilgilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(GetCurrentUserEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
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
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthLogoutSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginRegisterPage()),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthUserLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, ${state.user['user']['username']}',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  Text('You are logged in successfully!'),
                ],
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
