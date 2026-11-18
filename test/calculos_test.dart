import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_viaje/models/categoria.dart';
import 'package:gastos_viaje/models/gasto.dart';
import 'package:gastos_viaje/models/tasas_cambio.dart';
import 'package:gastos_viaje/utils/calculos.dart';

Gasto _gasto(double monto, String moneda) {
  return Gasto(
    viajeId: 1,
    descripcion: 'Prueba',
    monto: monto,
    moneda: moneda,
    categoria: Categoria.otros,
    fecha: DateTime(2026, 1, 1),
  );
}

void main() {
  final tasas = TasasCambio(
    base: 'COP',
    tasas: const {'COP': 1, 'USD': 0.00025},
    actualizacion: DateTime.utc(2026, 1, 1),
  );

  group('totalEnPesos', () {
    test('suma gastos en distintas monedas', () {
      final gastos = [_gasto(10, 'USD'), _gasto(5000, 'COP')];
      expect(totalEnPesos(gastos, tasas), closeTo(45000, 0.001));
    });

    test('sin gastos el total es cero', () {
      expect(totalEnPesos([], tasas), 0);
    });

    test('devuelve null si alguna moneda no tiene tasa', () {
      final gastos = [_gasto(10, 'USD'), _gasto(3, 'XXX')];
      expect(totalEnPesos(gastos, tasas), isNull);
    });
  });

  test('totalesPorMoneda agrupa sin convertir', () {
    final gastos = [_gasto(10, 'USD'), _gasto(5, 'USD'), _gasto(2000, 'COP')];
    expect(totalesPorMoneda(gastos), {'USD': 15.0, 'COP': 2000.0});
  });
}
