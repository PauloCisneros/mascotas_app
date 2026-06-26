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

  // 4. Obtener el ID del usuario actual
  String? getUserId() {
    return _client.auth.currentUser?.id;
  }

  // 5. Obtener el perfil completo del usuario
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select('id, nombres, apellidos, email, rol, sector_id')
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }

  // 6. Actualizar el sector del usuario
  Future<void> updateUserSector(String userId, String sectorId) async {
    await _client
        .from('profiles')
        .update({'sector_id': sectorId})
        .eq('id', userId);
  }
}
