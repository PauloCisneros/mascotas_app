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
  Map<String, dynamic>? _userProfile;

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
    _fetchUserProfile();
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

  Future<void> _fetchUserProfile() async {
    final profile = await _authService.getUserProfile(); // ahora lo trae directo
    setState(() {
      _userProfile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = _userProfile?['rol'];

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              accountName: Text(
                "${_userProfile?['nombres'] ?? ''} ${_userProfile?['apellidos'] ?? ''}",
              ),
              accountEmail: Text(_userProfile?['email'] ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _userProfile?['nombres'] != null
                      ? _userProfile!['nombres'][0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (role == 'coordinador_campana') ...[
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
            if (role == 'coordinador_brigada') ...[
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
            if (role == 'vacunador') ...[
              _buildNavButton("Registrar Nueva Vacunación", Icons.vaccines, () {
                Navigator.pushNamed(context, '/vaccination-form');
              }),
            ],
          ],
        ),
      ),
      body: _loadingMetrics
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildMetricCard("Sectores", _sectores, Icons.map, Colors.blue),
                  _buildMetricCard("Coordinadores", _brigadistas, Icons.group, Colors.orange),
                  _buildMetricCard("Vacunadores", _vacunadores, Icons.medical_services, Colors.green),
                  _buildMetricCard("Vacunaciones", _vacunaciones, Icons.vaccines, Colors.purple),
                ],
              ),
            ),
    );
  }

  Widget _buildNavButton(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }

  Widget _buildMetricCard(String title, int value, IconData icon, Color color) {
    return SizedBox(
      width: 160,
      height: 130,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(
                value.toString(),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
