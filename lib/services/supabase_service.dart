import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Patrón Singleton para acceder a la misma instancia en toda la app
  static final SupabaseService _instance = SupabaseService._internal();
  
  factory SupabaseService() => _instance;
  
  SupabaseService._internal();

  // Getter para acceder al cliente
  SupabaseClient get client => Supabase.instance.client;

  // Método para inicializar (llamar en main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'TU_SUPABASE_URL',
      anonKey: 'TU_SUPABASE_ANON_KEY',
    );
  }
}