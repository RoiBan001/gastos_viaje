import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_viaje/models/categoria.dart';
import 'package:gastos_viaje/models/gasto.dart';
import 'package:gastos_viaje/models/tasas_cambio.dart';
import 'package:gastos_viaje/models/viaje.dart';

void main() {
  group('Viaje', () {
    final viaje = Viaje(
      nombre: 'Vacaciones',
      destino: 'Lima',
      moneda: 'PEN',
      presupuestoCop: 3000000,
      fechaInicio: DateTime(2026, 12, 20),
    );

    test('toMap no incluye el id si todavía no existe', () {
      expect(viaje.toMap().containsKey('id'), isFalse);
    });

    test('toMap y fromMap conservan los datos', () {
      final copia = Viaje.fromMap(viaje.conId(7).toMap());
      expect(copia.id, 7);
      expect(copia.nombre, 'Vacaciones');
      expect(copia.moneda, 'PEN');
      expect(copia.presupuestoCop, 3000000);
      expect(copia.fechaInicio, DateTime(2026, 12, 20));
    });
  });

  group('Gasto', () {
    test('toMap y fromMap conservan la categoría', () {
      final gasto = Gasto(
        id: 1,
        viajeId: 7,
        descripcion: 'Taxi',
        monto: 25.5,
        moneda: 'USD',
        categoria: Categoria.transporte,
        fecha: DateTime(2026, 12, 21),
      );
      final mapa = gasto.toMap();
      expect(mapa['categoria'], 'transporte');
      expect(mapa['viaje_id'], 7);

      final copia = Gasto.fromMap(mapa);
      expect(copia.categoria, Categoria.transporte);
      expect(copia.monto, 25.5);
    });

    test('una categoría desconocida se lee como "otros"', () {
      expect(Categoria.desdeNombre('no_existe'), Categoria.otros);
    });
  });

  group('TasasCambio', () {
    final tasas = TasasCambio.fromJson({
      'result': 'success',
      'base_code': 'COP',
      'time_last_update_unix': 1767225600,
      'rates': {'COP': 1, 'USD': 0.00025, 'EUR': 0.0002},
    });

    test('lee la base, las tasas y la fecha', () {
      expect(tasas.base, 'COP');
      expect(tasas.tasas['USD'], 0.00025);
      expect(tasas.tasas['COP'], 1.0);
      expect(tasas.actualizacion.isUtc, isTrue);
    });

    test('convierte a pesos dividiendo por la tasa', () {
      expect(tasas.aBase(10, 'USD'), closeTo(40000, 0.001));
      expect(tasas.aBase(1, 'EUR'), closeTo(5000, 0.001));
    });

    test('los pesos no se convierten', () {
      expect(tasas.aBase(5000, 'COP'), 5000);
    });

    test('devuelve null si la moneda no tiene tasa', () {
      expect(tasas.aBase(1, 'XXX'), isNull);
    });
  });
}
