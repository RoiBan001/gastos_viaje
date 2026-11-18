import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_viaje/utils/formato.dart';

void main() {
  group('formatearNumero', () {
    test('separa los miles con punto', () {
      expect(formatearNumero(1234567), '1.234.567');
    });

    test('usa coma para los decimales', () {
      expect(formatearNumero(1234.5, decimales: 2), '1.234,50');
    });

    test('números pequeños y cero', () {
      expect(formatearNumero(0), '0');
      expect(formatearNumero(999), '999');
      expect(formatearNumero(1000), '1.000');
    });

    test('números negativos', () {
      expect(formatearNumero(-1500), '-1.500');
    });
  });

  test('formatearMoneda: pesos sin decimales y otras monedas con código', () {
    expect(formatearMoneda(3000, 'COP'), '\$ 3.000');
    expect(formatearMoneda(25.5, 'USD'), '25,50 USD');
  });

  test('formatearFecha usa dd/mm/aaaa', () {
    expect(formatearFecha(DateTime(2026, 3, 5)), '05/03/2026');
  });

  test('montoParaEditar quita el .0 de los enteros', () {
    expect(montoParaEditar(3000000), '3000000');
    expect(montoParaEditar(25.5), '25.5');
  });
}
