import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vaccination_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final _client = Supabase.instance.client;

  // --- GESTIÓN DE USUARIOS ---
  Future<void> createUser(
    String email,
    String password,
    String role,
    String sectorId, {
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
  }) async {
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (authResponse.user != null) {
      await _client.from('profiles').insert({
        'id': authResponse.user!.id,
        'email': email,
        'rol': role,
        'sector_id': sectorId,
        'is_first_login': true,
        'cedula': cedula,
        'nombres': nombres,
        'apellidos': apellidos,
        'telefono': telefono,
      });
    }
  }

  // Obtener usuarios por sector
  Future<List<Map<String, dynamic>>> getUsersBySector(String sectorId) async {
    final response = await _client
        .from('profiles')
        .select('*')
        .eq('sector_id', sectorId);

    return List<Map<String, dynamic>>.from(response);
  }

  // --- GESTIÓN DE VACUNACIONES ---
  
  // Guardar nueva vacunación
  Future<void> saveVaccination(VaccinationModel vaccination) async {
    await _client.from('vaccinations').insert(vaccination.toJson());
  }

  // Obtener registros filtrados por sector
  Future<List<Map<String, dynamic>>> getVaccinationsBySector(String sectorId) async {
    final response = await _client
        .from('vaccinations')
        .select('*')
        .eq('sector_id', sectorId);

    return List<Map<String, dynamic>>.from(response);
  }

  // Obtener registros paginados (para scroll infinito)
  Future<List<VaccinationModel>> getVaccinations({int page = 0, int limit = 10}) async {
    final response = await _client
        .from('vaccinations')
        .select('*')
        .order('created_at', ascending: false)
        .range(page * limit, (page + 1) * limit - 1);

    return (response as List)
        .map((e) => VaccinationModel.fromMap(e))
        .toList();
  }
}
