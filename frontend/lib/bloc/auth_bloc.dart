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
    on<LogoutEvent>(_onLogout);
    on<GetCurrentUserEvent>(_onGetCurrentUser);

    // Check for token and load user on initialization
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = Hive.box('authBox').get('token');
    if (token != null) {
      add(GetCurrentUserEvent());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.login(event.email, event.password);
      await Hive.box('authBox').put('token', token);
      emit(AuthSuccess());
      // Get user info after successful login
      add(GetCurrentUserEvent());
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
      // Get user info after successful registration
      add(GetCurrentUserEvent());
    } catch (e) {
      emit(AuthError(message: "Kayıt başarısız: ${e.toString()}"));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await Hive.box('authBox').delete('token');
    emit(AuthLogoutSuccess());
  }

  Future<void> _onGetCurrentUser(
    GetCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      emit(AuthUserLoaded(user: user));
    } catch (e) {
      emit(
        AuthError(message: "Kullanıcı bilgileri alınamadı: ${e.toString()}"),
      );
    }
  }
}
