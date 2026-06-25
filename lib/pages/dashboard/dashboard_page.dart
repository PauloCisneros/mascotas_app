import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Principal")),
      body: FutureBuilder<String?>(
        future: _authService.getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final role = snapshot.data;

          // Según el rol, devolvemos una vista distinta
          switch (role) {
            case 'coordinador_campana':
              return _buildCoordinadorCampanaView();
            case 'coordinador_brigada':
              return _buildCoordinadorBrigadaView();
            case 'vacunador':
              return _buildVacunadorView();
            default:
              return const Center(child: Text("Rol no reconocido"));
          }
        },
      ),
    );
  }

  // Vistas simplificadas por rol
  Widget _buildCoordinadorCampanaView() {
    return ListView(children: const [
      ListTile(title: Text("Crear Sectores")),
      ListTile(title: Text("Crear Coordinadores de Brigada")),
    ]);
  }

  Widget _buildCoordinadorBrigadaView() {
    return ListView(children: const [
      ListTile(title: Text("Ver sectores asignados")),
      ListTile(title: Text("Crear Vacunadores")),
    ]);
  }

  Widget _buildVacunadorView() {
    return Center(
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/vaccination-form'),
        child: const Text("Registrar Nueva Vacunación"),
      ),
    );
  }
}