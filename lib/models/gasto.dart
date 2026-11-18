import 'categoria.dart';

/// Un gasto hecho durante un viaje. Se guarda en la tabla `gastos`.
class Gasto {
  const Gasto({
    this.id,
    required this.viajeId,
    required this.descripcion,
    required this.monto,
    required this.moneda,
    required this.categoria,
    required this.fecha,
  });

  /// Lo asigna SQLite al insertar. Es null mientras el gasto no se ha guardado.
  final int? id;

  /// Id del viaje al que pertenece el gasto (llave foránea).
  final int viajeId;
  final String descripcion;

  /// Valor del gasto en su moneda original.
  final double monto;

  /// Código ISO 4217 de la moneda en que se pagó, por ejemplo 'USD'.
  final String moneda;
  final Categoria categoria;
  final DateTime fecha;

  /// Copia del gasto con el id que asignó la base de datos.
  Gasto conId(int nuevoId) {
    return Gasto(
      id: nuevoId,
      viajeId: viajeId,
      descripcion: descripcion,
      monto: monto,
      moneda: moneda,
      categoria: categoria,
      fecha: fecha,
    );
  }

  /// Convierte el gasto en una fila para SQLite.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'viaje_id': viajeId,
      'descripcion': descripcion,
      'monto': monto,
      'moneda': moneda,
      'categoria': categoria.name,
      'fecha': fecha.toIso8601String(),
    };
  }

  /// Crea un gasto a partir de una fila de SQLite.
  factory Gasto.fromMap(Map<String, Object?> mapa) {
    return Gasto(
      id: mapa['id'] as int?,
      viajeId: mapa['viaje_id'] as int,
      descripcion: mapa['descripcion'] as String,
      monto: (mapa['monto'] as num).toDouble(),
      moneda: mapa['moneda'] as String,
      categoria: Categoria.desdeNombre(mapa['categoria'] as String),
      fecha: DateTime.parse(mapa['fecha'] as String),
    );
  }
}
