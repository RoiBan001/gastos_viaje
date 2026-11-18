import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/gasto.dart';
import '../models/viaje.dart';

/// Acceso a la base de datos SQLite del dispositivo.
///
/// Es un singleton: toda la app usa la misma instancia
/// ([BaseDatos.instancia]) y la misma conexión abierta.
class BaseDatos {
  BaseDatos._();

  static final BaseDatos instancia = BaseDatos._();

  static const String _nombreArchivo = 'gastos_viaje.db';
  static const int _version = 1;

  Database? _db;

  /// Devuelve la conexión. La primera vez abre (o crea) el archivo.
  Future<Database> get _baseDatos async {
    return _db ??= await _abrir();
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), _nombreArchivo);
    return openDatabase(
      ruta,
      version: _version,
      // SQLite trae las llaves foráneas apagadas: hay que encenderlas
      // en cada conexión para que funcione el ON DELETE CASCADE.
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      // Solo se ejecuta la primera vez, cuando el archivo no existe.
      onCreate: _crearTablas,
    );
  }

  Future<void> _crearTablas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE viajes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        destino TEXT NOT NULL,
        moneda TEXT NOT NULL,
        presupuesto_cop REAL NOT NULL,
        fecha_inicio TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        viaje_id INTEGER NOT NULL,
        descripcion TEXT NOT NULL,
        monto REAL NOT NULL,
        moneda TEXT NOT NULL,
        categoria TEXT NOT NULL,
        fecha TEXT NOT NULL,
        FOREIGN KEY (viaje_id) REFERENCES viajes (id) ON DELETE CASCADE
      )
    ''');
  }

  // ---------------------------------------------------------------- Viajes

  Future<List<Viaje>> obtenerViajes() async {
    final db = await _baseDatos;
    final filas = await db.query('viajes', orderBy: 'fecha_inicio DESC');
    return filas.map(Viaje.fromMap).toList();
  }

  /// Inserta el viaje y lo devuelve con el id que le asignó SQLite.
  Future<Viaje> insertarViaje(Viaje viaje) async {
    final db = await _baseDatos;
    final id = await db.insert('viajes', viaje.toMap());
    return viaje.conId(id);
  }

  Future<void> actualizarViaje(Viaje viaje) async {
    final db = await _baseDatos;
    await db.update(
      'viajes',
      viaje.toMap(),
      where: 'id = ?',
      whereArgs: [viaje.id],
    );
  }

  /// Borra el viaje. Sus gastos se borran solos por el ON DELETE CASCADE.
  Future<void> eliminarViaje(int id) async {
    final db = await _baseDatos;
    await db.delete('viajes', where: 'id = ?', whereArgs: [id]);
  }

  /// Cuántos gastos tiene cada viaje: {idViaje: cantidad}.
  Future<Map<int, int>> contarGastosPorViaje() async {
    final db = await _baseDatos;
    final filas = await db.rawQuery(
      'SELECT viaje_id, COUNT(*) AS cantidad FROM gastos GROUP BY viaje_id',
    );
    return {
      for (final fila in filas)
        (fila['viaje_id'] as int): (fila['cantidad'] as int),
    };
  }

  // ---------------------------------------------------------------- Gastos

  Future<List<Gasto>> obtenerGastos(int viajeId) async {
    final db = await _baseDatos;
    final filas = await db.query(
      'gastos',
      where: 'viaje_id = ?',
      whereArgs: [viajeId],
      orderBy: 'fecha DESC, id DESC',
    );
    return filas.map(Gasto.fromMap).toList();
  }

  /// Inserta el gasto y lo devuelve con el id que le asignó SQLite.
  Future<Gasto> insertarGasto(Gasto gasto) async {
    final db = await _baseDatos;
    final id = await db.insert('gastos', gasto.toMap());
    return gasto.conId(id);
  }

  Future<void> actualizarGasto(Gasto gasto) async {
    final db = await _baseDatos;
    await db.update(
      'gastos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  Future<void> eliminarGasto(int id) async {
    final db = await _baseDatos;
    await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }
}
