import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_viaje/services/tasas_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Pruebas del servicio de la API con un cliente HTTP falso (MockClient):
/// no se conectan a internet y permiten simular cada tipo de error.
void main() {
  final respuestaExitosa = jsonEncode({
    'result': 'success',
    'base_code': 'COP',
    'time_last_update_unix': 1767225600,
    'rates': {'COP': 1, 'USD': 0.00025},
  });

  TasasApiService servicioQueResponde(http.Response respuesta) {
    return TasasApiService(
      cliente: MockClient((request) async => respuesta),
    );
  }

  test('devuelve las tasas cuando la API responde bien', () async {
    final servicio = TasasApiService(
      cliente: MockClient((request) async {
        // Verifica que se consulta la URL correcta
        expect(
          request.url.toString(),
          'https://open.er-api.com/v6/latest/COP',
        );
        return http.Response(respuestaExitosa, 200);
      }),
    );

    final tasas = await servicio.obtenerTasas('COP');
    expect(tasas.base, 'COP');
    expect(tasas.tasas['USD'], 0.00025);
  });

  test('error del servidor (500)', () async {
    final servicio = servicioQueResponde(http.Response('', 500));
    await expectLater(
      servicio.obtenerTasas('COP'),
      throwsA(isA<ApiException>()),
    );
  });

  test('demasiadas consultas (429)', () async {
    final servicio = servicioQueResponde(http.Response('', 429));
    await expectLater(
      servicio.obtenerTasas('COP'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          contains('demasiadas consultas'),
        ),
      ),
    );
  });

  test('respuesta que no es JSON', () async {
    final servicio = servicioQueResponde(http.Response('<html></html>', 200));
    await expectLater(
      servicio.obtenerTasas('COP'),
      throwsA(isA<ApiException>()),
    );
  });

  test('la API responde result = error', () async {
    final servicio = servicioQueResponde(
      http.Response(jsonEncode({'result': 'error'}), 200),
    );
    await expectLater(
      servicio.obtenerTasas('COP'),
      throwsA(isA<ApiException>()),
    );
  });

  test('sin conexión a internet', () async {
    final servicio = TasasApiService(
      cliente: MockClient(
        (request) async => throw const SocketException('Sin red'),
      ),
    );
    await expectLater(
      servicio.obtenerTasas('COP'),
      throwsA(isA<ApiException>()),
    );
  });

  test('tiempo de espera agotado', () async {
    final servicio = TasasApiService(
      tiempoEspera: const Duration(milliseconds: 50),
      cliente: MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        return http.Response(respuestaExitosa, 200);
      }),
    );
    await expectLater(
      servicio.obtenerTasas('COP'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          contains('tardó demasiado'),
        ),
      ),
    );
  });
}
