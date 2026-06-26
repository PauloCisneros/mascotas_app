class VaccinationModel {
  final String? id;
  final String propietario;
  final String cedula;
  final String telefono;
  final String mascotaNombre;
  final String tipo; // Perro o Gato
  final String edad;
  final String sexo; // Macho o Hembra
  final String vacuna;
  final String observaciones;
  final String? fotoUrl;
  final double latitud;
  final double longitud;
  final DateTime fecha;

  VaccinationModel({
    this.id,
    required this.propietario,
    required this.cedula,
    required this.telefono,
    required this.mascotaNombre,
    required this.tipo,
    required this.edad,
    required this.sexo,
    required this.vacuna,
    required this.observaciones,
    this.fotoUrl,
    required this.latitud,
    required this.longitud,
    required this.fecha,
  });

  // Para enviar datos a Supabase
  Map<String, dynamic> toJson() {
    return {
      'propietario_nombre': propietario,
      'propietario_cedula': cedula,
      'propietario_telefono': telefono,
      'mascota_nombre': mascotaNombre,
      'tipo_mascota': tipo,
      'edad_aproximada': edad,
      'sexo': sexo,
      'vacuna_aplicada': vacuna,
      'observaciones': observaciones,
      'foto_url': fotoUrl,
      'latitud': latitud,
      'longitud': longitud,
      'created_at': fecha.toIso8601String(),
    };
  }

  // Crear objeto desde Map (para leer de Supabase)
  factory VaccinationModel.fromMap(Map<String, dynamic> map) {
    return VaccinationModel(
      id: map['id']?.toString(),
      propietario: map['propietario_nombre'] ?? '',
      cedula: map['propietario_cedula'] ?? '',
      telefono: map['propietario_telefono'] ?? '',
      mascotaNombre: map['mascota_nombre'] ?? '',
      tipo: map['tipo_mascota'] ?? '',
      edad: map['edad_aproximada'] ?? '',
      sexo: map['sexo'] ?? '',
      vacuna: map['vacuna_aplicada'] ?? '',
      observaciones: map['observaciones'] ?? '',
      fotoUrl: map['foto_url'],
      latitud: (map['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (map['longitud'] as num?)?.toDouble() ?? 0.0,
      fecha: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }
}
