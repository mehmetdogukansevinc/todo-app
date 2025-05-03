import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../repository/auth_repo.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.login(event.email, event.password);
      await Hive.box('authBox').put('token', token);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(message: "Giriş başarısız: ${e.toString()}"));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.register(
        event.username,
        event.email,
        event.password,
      );
      await Hive.box('authBox').put('token', token);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(message: "Kayıt başarısız: ${e.toString()}"));
    }
  }
}
