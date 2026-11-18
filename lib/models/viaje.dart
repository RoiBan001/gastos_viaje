/// Un viaje registrado por el usuario. Se guarda en la tabla `viajes`.
class Viaje {
  const Viaje({
    this.id,
    required this.nombre,
    required this.destino,
    required this.moneda,
    required this.presupuestoCop,
    required this.fechaInicio,
  });

  /// Lo asigna SQLite al insertar. Es null mientras el viaje no se ha guardado.
  final int? id;
  final String nombre;
  final String destino;

  /// Código ISO 4217 de la moneda del destino, por ejemplo 'EUR'.
  final String moneda;

  /// Presupuesto total del viaje, en pesos colombianos.
  final double presupuestoCop;
  final DateTime fechaInicio;

  /// Copia del viaje con el id que asignó la base de datos.
  Viaje conId(int nuevoId) {
    return Viaje(
      id: nuevoId,
      nombre: nombre,
      destino: destino,
      moneda: moneda,
      presupuestoCop: presupuestoCop,
      fechaInicio: fechaInicio,
    );
  }

  /// Convierte el viaje en una fila para SQLite.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'destino': destino,
      'moneda': moneda,
      'presupuesto_cop': presupuestoCop,
      'fecha_inicio': fechaInicio.toIso8601String(),
    };
  }

  /// Crea un viaje a partir de una fila de SQLite.
  factory Viaje.fromMap(Map<String, Object?> mapa) {
    return Viaje(
      id: mapa['id'] as int?,
      nombre: mapa['nombre'] as String,
      destino: mapa['destino'] as String,
      moneda: mapa['moneda'] as String,
      presupuestoCop: (mapa['presupuesto_cop'] as num).toDouble(),
      fechaInicio: DateTime.parse(mapa['fecha_inicio'] as String),
    );
  }
}
