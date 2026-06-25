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
              return _buildCoordinadorCampanaView(context);
            case 'coordinador_brigada':
              return _buildCoordinadorBrigadaView(context);
            case 'vacunador':
              return _buildVacunadorView(context);
            default:
              return const Center(child: Text("Rol no reconocido"));
          }
        },
      ),
    );
  }

  // Vistas por rol
  Widget _buildCoordinadorCampanaView(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text("Crear Sectores"),
          onTap: () => Navigator.pushNamed(context, '/sector-management'),
        ),
        ListTile(
          title: const Text("Crear Coordinadores de Brigada"),
          onTap: () {
            // Aquí luego puedes enlazar a la página de gestión de coordinadores
          },
        ),
      ],
    );
  }

  Widget _buildCoordinadorBrigadaView(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text("Ver sectores asignados"),
          onTap: () {
            // Aquí enlazas a la vista de sectores asignados
          },
        ),
        ListTile(
          title: const Text("Crear Vacunadores"),
          onTap: () {
            // Aquí enlazas a la página de gestión de vacunadores
          },
        ),
      ],
    );
  }

  Widget _buildVacunadorView(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/vaccination-form'),
        child: const Text("Registrar Nueva Vacunación"),
      ),
    );
  }
}
