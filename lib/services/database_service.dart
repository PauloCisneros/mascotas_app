import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vaccination_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final _client = Supabase.instance.client;
  static const String initialPassword = 'Ecuador2026';

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
    // 1. Crear usuario en Auth
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );

    // 2. Insertar en profiles
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

  Future<List<Map<String, dynamic>>> getUsersBySector(String sectorId) async {
    final response = await _client
        .from('profiles')
        .select('*')
        .eq('sector_id', sectorId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    final response = await _client
        .from('profiles')
        .select('*')
        .eq('rol', role);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<int> countUsersByRole(String role) async {
    final response = await _client
        .from('profiles')
        .count(CountOption.exact)
        .eq('rol', role);
    return response;
  }

  Future<void> updateUserSector(String userId, String sectorId) async {
    await _client
        .from('profiles')
        .update({'sector_id': sectorId})
        .eq('id', userId);
  }

  Future<List<Map<String, dynamic>>> getVaccinatorsBySector(String sectorId) async {
    final response = await _client
        .from('profiles')
        .select('*')
        .eq('sector_id', sectorId)
        .eq('rol', 'vacunador');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select('id, nombres, apellidos, email, rol, sector_id')
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  // --- GESTIÓN DE SECTORES ---
  Future<List<Map<String, dynamic>>> getSectors() async {
    final response = await _client.from('sectors').select('*');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getSectorById(String sectorId) async {
    final response = await _client
        .from('sectors')
        .select('*')
        .eq('id', sectorId)
        .maybeSingle();
    return response;
  }

  Future<int> countSectors() async {
    final response = await _client.from('sectors').count(CountOption.exact);
    return response;
  }

  // --- GESTIÓN DE VACUNACIONES ---
  Future<void> saveVaccination(VaccinationModel vaccination) async {
    await _client.from('vaccinations').insert(vaccination.toJson());
  }

  Future<List<Map<String, dynamic>>> getVaccinationsBySector(String sectorId) async {
    final response = await _client
        .from('vaccinations')
        .select('*')
        .eq('sector_id', sectorId);
    return List<Map<String, dynamic>>.from(response);
  }

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

  Future<int> countVaccinations({String? sectorId}) async {
    var query = _client.from('vaccinations').select('id');

    if (sectorId != null) {
      query = query.eq('sector_id', sectorId);
    }

    final response = await query;
    return response.length;
  }

  // --- MÉTRICAS ESPECÍFICAS ---
  Future<int> countDogsVaccinated({String? sectorId}) async {
    var query = _client
        .from('vaccinations')
        .select('id')
        .eq('tipo_mascota', 'perro');

    if (sectorId != null) {
      query = query.eq('sector_id', sectorId);
    }

    final response = await query;
    return response.length;
  }

  Future<int> countCatsVaccinated({String? sectorId}) async {
    var query = _client
        .from('vaccinations')
        .select('id')
        .eq('tipo_mascota', 'gato');

    if (sectorId != null) {
      query = query.eq('sector_id', sectorId);
    }

    final response = await query;
    return response.length;
  }

  Future<void> updateVaccination(VaccinationModel registro) async {
    await _client
        .from('vaccinations')
        .update(registro.toJson())
        .eq('id', registro.id!); 
  }
}
