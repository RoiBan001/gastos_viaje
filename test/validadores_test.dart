import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_viaje/utils/validadores.dart';

void main() {
  group('validarObligatorio', () {
    test('rechaza vacío y solo espacios', () {
      expect(validarObligatorio(''), isNotNull);
      expect(validarObligatorio('   '), isNotNull);
      expect(validarObligatorio(null), isNotNull);
    });

    test('acepta texto', () {
      expect(validarObligatorio('Lima'), isNull);
    });

    test('usa el nombre del campo en el mensaje', () {
      expect(validarObligatorio('', campo: 'El destino'),
          'El destino es obligatorio');
    });
  });

  group('leerMonto', () {
    test('acepta coma o punto decimal', () {
      expect(leerMonto('25,5'), 25.5);
      expect(leerMonto('25.5'), 25.5);
      expect(leerMonto(' 3000000 '), 3000000);
    });

    test('devuelve null si no es número', () {
      expect(leerMonto('abc'), isNull);
      expect(leerMonto('1.500.000'), isNull);
    });
  });

  group('validarMonto', () {
    test('rechaza vacío, texto, cero y negativos', () {
      expect(validarMonto(''), isNotNull);
      expect(validarMonto('abc'), isNotNull);
      expect(validarMonto('0'), isNotNull);
      expect(validarMonto('-5'), isNotNull);
    });

    test('acepta montos positivos', () {
      expect(validarMonto('25,50'), isNull);
      expect(validarMonto('3000000'), isNull);
    });
  });
}
