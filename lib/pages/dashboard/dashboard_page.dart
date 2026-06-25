import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _authService = AuthService();
  final _dbService = DatabaseService();

  int _sectores = 0;
  int _brigadistas = 0;
  int _vacunadores = 0;
  int _vacunaciones = 0;
  bool _loadingMetrics = true;

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMetrics();
  }

  Future<void> _fetchMetrics() async {
    final sectores = await _dbService.countSectors();
    final brigadistas = await _dbService.countUsersByRole('coordinador_brigada');
    final vacunadores = await _dbService.countUsersByRole('vacunador');
    final vacunaciones = await _dbService.countVaccinations();

    setState(() {
      _sectores = sectores;
      _brigadistas = brigadistas;
      _vacunadores = vacunadores;
      _vacunaciones = vacunaciones;
      _loadingMetrics = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Principal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: _authService.getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final role = snapshot.data;

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

  Widget _buildCoordinadorCampanaView(BuildContext context) {
    return Row(
      children: [
        // Botones de navegación a la izquierda
        Expanded(
          flex: 1,
          child: ListView(
            children: [
              ListTile(
                title: const Text("Crear Sectores"),
                onTap: () => Navigator.pushNamed(context, '/sector-management'),
              ),
              ListTile(
                title: const Text("Crear Coordinadores de Brigada"),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/user-management',
                  arguments: {
                    'currentRole': 'coordinador_campana',
                    'sectorId': 'sector-id',
                  },
                ),
              ),
            ],
          ),
        ),
        // Métricas a la derecha
        Expanded(
          flex: 2,
          child: _loadingMetrics
              ? const Center(child: CircularProgressIndicator())
              : GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildCard("Sectores", _sectores, Icons.map),
                    _buildCard("Coordinadores de Brigada", _brigadistas, Icons.group),
                    _buildCard("Vacunadores", _vacunadores, Icons.medical_services),
                    _buildCard("Vacunaciones", _vacunaciones, Icons.vaccines),
                  ],
                ),
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
          onTap: () => Navigator.pushNamed(
            context,
            '/user-management',
            arguments: {
              'currentRole': 'coordinador_brigada',
              'sectorId': 'sector-id',
            },
          ),
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

  Widget _buildCard(String title, int value, IconData icon) {
    return Card(
      elevation: 4,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value.toString(), style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
