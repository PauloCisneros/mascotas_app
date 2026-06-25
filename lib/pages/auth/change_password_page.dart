import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Las contraseñas no coinciden")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Actualizamos la contraseña en Supabase Auth
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );
      
      // 2. Opcional: Actualizamos el campo 'is_first_login' en tu tabla 'profiles'
      await Supabase.instance.client
          .from('profiles')
          .update({'is_first_login': false})
          .eq('id', Supabase.instance.client.auth.currentUser!.id);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cambiar Contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Es tu primer inicio de sesión. Por favor, cambia tu contraseña."),
            TextField(controller: _newPasswordController, decoration: const InputDecoration(labelText: "Nueva Contraseña"), obscureText: true),
            TextField(controller: _confirmPasswordController, decoration: const InputDecoration(labelText: "Confirmar Contraseña"), obscureText: true),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator() 
              : ElevatedButton(onPressed: _updatePassword, child: const Text("Actualizar")),
          ],
        ),
      ),
    );
  }
}