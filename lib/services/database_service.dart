import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vaccination_model.dart';

class DatabaseService {
  final _client = Supabase.instance.client;

  // --- GESTIÓN DE USUARIOS (CREAR) ---
  // Nota: Para crear usuarios autenticados, usamos auth.signUp
  Future<void> createUser(String email, String password, String role, String sectorId) async {
    final authResponse = await _client.auth.signUp(email: email, password: password);
    
    if (authResponse.user != null) {
      // Guardar información adicional en la tabla profiles
      await _client.from('profiles').insert({
        'id': authResponse.user!.id,
        'rol': role,
        'sector_id': sectorId,
        'is_first_login': true,
      });
    }
  }

  // --- GESTIÓN DE VACUNACIONES ---
  
  // Guardar nueva vacunación
  Future<void> saveVaccination(VaccinationModel vaccination) async {
    await _client.from('vaccinations').insert(vaccination.toJson());
  }

  // Obtener registros (puedes filtrar por sector aquí)
  Future<List<Map<String, dynamic>>> getVaccinations(String sectorId) async {
    return await _client
        .from('vaccinations')
        .select('*')
        .eq('sector_id', sectorId);
  }
}