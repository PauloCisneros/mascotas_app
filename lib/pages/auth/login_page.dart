import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('is_first_login')
            .eq('id', user.id)
            .maybeSingle();

        if (!mounted) return;

        if (profile == null) {
          throw Exception("Perfil de usuario no encontrado. Contacte al administrador.");
        }

        if (profile['is_first_login'] == true) {
          Navigator.pushReplacementNamed(context, '/change-password');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Icono
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.vaccines, size: 50, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              const Text(
                "Campaña de Vacunación",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 32),

              // Campo correo
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email, color: Colors.blue),
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Campo contraseña
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                  labelText: "Contraseña",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Botón login
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text("Ingresar"),
                      ),
                    ),

              const SizedBox(height: 16),

              // Texto adicional
              TextButton(
                onPressed: () {
                  // Aquí podrías enlazar a recuperación de contraseña
                },
                child: const Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
