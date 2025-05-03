abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}

class AuthLogoutSuccess extends AuthState {}

class AuthUserLoaded extends AuthState {
  final dynamic user;

  AuthUserLoaded({required this.user});
}
