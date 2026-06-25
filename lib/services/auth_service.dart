import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService().client;

  // 1. Iniciar sesión
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  // 2. Obtener el rol del usuario (crítico para la seguridad)
  Future<String?> getUserRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select('rol')
        .eq('id', user.id)
        .single();
    
    return data['rol'] as String?;
  }

  // 3. Cerrar sesión
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}