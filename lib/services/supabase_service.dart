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
      url: 'https://rkjqsemrmnofgznhxynb.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJranFzZW1ybW5vZmd6bmh4eW5iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNzYzNjIsImV4cCI6MjA5Mzc1MjM2Mn0.QkB9bwpDO2IAhE1d4wjgyxoInicMKqZMzaSz5HY3erQ',
    );
  }
}