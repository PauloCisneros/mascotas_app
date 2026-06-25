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
    setState(() => _loadingMetrics = true);

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
            icon: const Icon(Icons.refresh),
            tooltip: "Recargar métricas",
            onPressed: _fetchMetrics,
          ),
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
          child: Container(
            color: Colors.grey.shade200,
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildNavButton("Crear Sectores", Icons.map, () {
                  Navigator.pushNamed(context, '/sector-management');
                }),
                _buildNavButton("Crear Coordinadores de Brigada", Icons.group_add, () {
                  Navigator.pushNamed(
                    context,
                    '/user-management',
                    arguments: {
                      'currentRole': 'coordinador_campana',
                      'sectorId': 'sector-id',
                    },
                  );
                }),
              ],
            ),
          ),
        ),
        // Métricas a la derecha
        Expanded(
          flex: 2,
          child: _loadingMetrics
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildMetricCard("Sectores", _sectores, Icons.map, Colors.blue),
                      _buildMetricCard("Coordinadores", _brigadistas, Icons.group, Colors.orange),
                      _buildMetricCard("Vacunadores", _vacunadores, Icons.medical_services, Colors.green),
                      _buildMetricCard("Vacunaciones", _vacunaciones, Icons.vaccines, Colors.purple),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildNavButton(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMetricCard(String title, int value, IconData icon, Color color) {
    return SizedBox(
      width: 150,
      height: 120,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(
                value.toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinadorBrigadaView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildNavButton("Ver sectores asignados", Icons.visibility, () {
          // Aquí enlazas a la vista de sectores asignados
        }),
        _buildNavButton("Crear Vacunadores", Icons.person_add, () {
          Navigator.pushNamed(
            context,
            '/user-management',
            arguments: {
              'currentRole': 'coordinador_brigada',
              'sectorId': 'sector-id',
            },
          );
        }),
      ],
    );
  }

  Widget _buildVacunadorView(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.vaccines),
        onPressed: () => Navigator.pushNamed(context, '/vaccination-form'),
        label: const Text("Registrar Nueva Vacunación"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
