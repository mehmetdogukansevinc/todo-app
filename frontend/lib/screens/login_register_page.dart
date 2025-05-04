import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'home_page.dart';

class LoginRegisterPage extends StatefulWidget {
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool isLogin = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _switchMode() {
    setState(() {
      isLogin = !isLogin;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Handle loading state
          if (state is AuthLoading) {
            // Do nothing, show loading indicator
          }
          // Handle success state
          else if (state is AuthSuccess) {
            if (!_isNavigating) {
              _isNavigating = true;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Başarılı!'),
                  backgroundColor: Colors.green,
                ),
              );

              // Delay navigation to HomePage to prevent racing with GetCurrentUserEvent
              Future.delayed(Duration(milliseconds: 500), () {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
              });
            }
          }
          // Handle user loaded state
          else if (state is AuthUserLoaded) {
            if (!_isNavigating) {
              _isNavigating = true;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          }
          // Handle error state
          else if (state is AuthError) {
            _isNavigating = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade700, Colors.purple.shade500],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo veya ikon
                              Icon(
                                Icons.note_alt_outlined,
                                size: 80,
                                color: Colors.purple.shade700,
                              ),
                              SizedBox(height: 24),
                              // Başlık
                              Text(
                                isLogin
                                    ? 'Not Uygulamasına Hoş Geldiniz'
                                    : 'Yeni Hesap Oluştur',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 32),

                              // Form alanları
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Column(
                                  children: [
                                    if (!isLogin)
                                      _buildTextField(
                                        controller: _usernameController,
                                        label: 'Kullanıcı Adı',
                                        icon: Icons.person,
                                        validator: (value) {
                                          if (!isLogin &&
                                              (value == null ||
                                                  value.isEmpty)) {
                                            return 'Kullanıcı adı gerekli';
                                          } else if (!isLogin &&
                                              value != null &&
                                              value.length < 3) {
                                            return 'Kullanıcı adı en az 3 karakter olmalı';
                                          }
                                          return null;
                                        },
                                      ),
                                    SizedBox(height: isLogin ? 0 : 16),
                                    _buildTextField(
                                      controller: _emailController,
                                      label: 'Email Adresi',
                                      icon: Icons.email,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Email adresi gerekli';
                                        } else if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                        ).hasMatch(value)) {
                                          return 'Geçerli bir email adresi girin';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _passwordController,
                                      label: 'Şifre',
                                      icon: Icons.lock,
                                      isPassword: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Şifre gerekli';
                                        } else if (value.length < 6) {
                                          return 'Şifre en az 6 karakter olmalı';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 32),

                              // Butonlar
                              if (state is AuthLoading)
                                CircularProgressIndicator(
                                  color: Colors.purple.shade700,
                                )
                              else
                                Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: _submitForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple.shade700,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 48,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: Text(
                                        isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    TextButton(
                                      onPressed: _switchMode,
                                      child: Text(
                                        isLogin
                                            ? 'Hesabınız yok mu? Kayıt olun'
                                            : 'Zaten hesabınız var mı? Giriş yapın',
                                        style: TextStyle(
                                          color: Colors.purple.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple.shade700, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(vertical: 16),
      ),
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() == true) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final username = _usernameController.text.trim();

      if (isLogin) {
        context.read<AuthBloc>().add(
          LoginEvent(email: email, password: password),
        );
      } else {
        context.read<AuthBloc>().add(
          RegisterEvent(email: email, password: password, username: username),
        );
      }
    }
  }
}
