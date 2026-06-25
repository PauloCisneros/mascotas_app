import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Asegúrate de importar el archivo que creamos
import '../services/supabase_service.dart'; 

void main() async {
  // 1. Necesario para inicializar bindings antes de tareas asíncronas
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializamos Supabase antes de arrancar la aplicación
  await SupabaseService.initialize();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Supabase Inicializado Correctamente'),
        ),
      ),
    );
  }
}