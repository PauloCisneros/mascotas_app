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
      // 1. Intentar inicio de sesión
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2. Obtener el usuario actual
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user != null) {
        // 3. Consultar si es su primer inicio de sesión desde la tabla profiles
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('is_first_login')
            .eq('id', user.id)
            .single();

        if (mounted) {
          if (profile['is_first_login'] == true) {
            // Redirigir a cambio de contraseña
            Navigator.pushReplacementNamed(context, '/change-password');
          } else {
            // Redirigir al dashboard normal
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campaña de Vacunación")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Correo")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Contraseña"), obscureText: true),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator() 
              : ElevatedButton(onPressed: _login, child: const Text("Ingresar")),
          ],
        ),
      ),
    );
  }
}