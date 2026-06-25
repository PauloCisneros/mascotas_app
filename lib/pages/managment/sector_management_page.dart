import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SectorManagementPage extends StatefulWidget {
  const SectorManagementPage({super.key});

  @override
  State<SectorManagementPage> createState() => _SectorManagementPageState();
}

class _SectorManagementPageState extends State<SectorManagementPage> {
  final _nombreController = TextEditingController();
  final client = Supabase.instance.client;

  Future<void> _addSector() async {
    if (_nombreController.text.trim().isEmpty) return;

    try {
      await client.from('sectors').insert({
        'nombre': _nombreController.text.trim(),
      });

      _nombreController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sector creado exitosamente")),
      );
      setState(() {}); // refrescar lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getSectors() async {
    final response = await client.from('sectors').select();
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Sectores")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: "Nombre del sector"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addSector,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getSectors(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final sectores = snapshot.data!;
                if (sectores.isEmpty) {
                  return const Center(child: Text("No hay sectores registrados"));
                }
                return ListView.builder(
                  itemCount: sectores.length,
                  itemBuilder: (context, index) {
                    final sector = sectores[index];
                    return ListTile(
                      title: Text(sector['nombre']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
