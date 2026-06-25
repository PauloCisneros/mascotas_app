class VaccinationModel {
  final String? id;
  final String propietario;
  final String cedula;
  final String mascotaNombre;
  final String tipo; // Perro o Gato
  final String? fotoUrl;
  final double latitud;
  final double longitud;
  final DateTime? fecha;

  VaccinationModel({
    this.id,
    required this.propietario,
    required this.cedula,
    required this.mascotaNombre,
    required this.tipo,
    this.fotoUrl,
    required this.latitud,
    required this.longitud,
    this.fecha,
  });

  // Para enviar datos a Supabase
  Map<String, dynamic> toJson() {
    return {
      'propietario_nombre': propietario,
      'propietario_cedula': cedula,
      'mascota_nombre': mascotaNombre,
      'tipo_mascota': tipo,
      'foto_url': fotoUrl,
      'latitud': latitud,
      'longitud': longitud,
      'created_at': fecha?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // crear objeto desde Map (para leer de Supabase)
  factory VaccinationModel.fromMap(Map<String, dynamic> map) {
    return VaccinationModel(
      id: map['id']?.toString(),
      propietario: map['propietario_nombre'] ?? '',
      cedula: map['propietario_cedula'] ?? '',
      mascotaNombre: map['mascota_nombre'] ?? '',
      tipo: map['tipo_mascota'] ?? '',
      fotoUrl: map['foto_url'],
      latitud: (map['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (map['longitud'] as num?)?.toDouble() ?? 0.0,
      fecha: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}
