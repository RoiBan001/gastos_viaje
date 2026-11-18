import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/tasas_cambio.dart';

/// Error controlado de la API, con un mensaje listo para mostrar al usuario.
class ApiException implements Exception {
  const ApiException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Consulta las tasas de cambio en ExchangeRate-API (endpoint abierto,
/// no necesita clave): https://www.exchangerate-api.com/docs/free
class TasasApiService {
  TasasApiService({
    http.Client? cliente,
    this.tiempoEspera = const Duration(seconds: 10),
  }) : _cliente = cliente ?? http.Client();

  static const String urlBase = 'https://open.er-api.com/v6/latest';

  /// Se puede reemplazar por un cliente falso en las pruebas.
  final http.Client _cliente;

  /// Si la API no responde en este tiempo, se cancela la espera.
  final Duration tiempoEspera;

  /// Pide las tasas con [monedaBase] como base, por ejemplo 'COP'.
  ///
  /// Lanza [ApiException] si no hay conexión, si se agota el tiempo de
  /// espera o si la respuesta no es válida.
  Future<TasasCambio> obtenerTasas(String monedaBase) async {
    final uri = Uri.parse('$urlBase/$monedaBase');
    try {
      final respuesta = await _cliente.get(uri).timeout(tiempoEspera);
      return _procesar(respuesta);
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder. Intenta de nuevo.',
      );
    } on SocketException {
      throw const ApiException(
        'Sin conexión a internet. Revisa tu red e intenta de nuevo.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No se pudo conectar con el servidor de tasas de cambio.',
      );
    }
  }

  TasasCambio _procesar(http.Response respuesta) {
    if (respuesta.statusCode == 429) {
      throw const ApiException(
        'Se hicieron demasiadas consultas. Espera unos minutos.',
      );
    }
    if (respuesta.statusCode != 200) {
      throw ApiException(
        'El servidor respondió con un error (código ${respuesta.statusCode}).',
      );
    }
    final datos = _decodificar(respuesta.body);
    if (datos is! Map<String, dynamic> || datos['result'] != 'success') {
      throw const ApiException(
        'El servidor no pudo entregar las tasas de cambio.',
      );
    }
    return TasasCambio.fromJson(datos);
  }

  Object? _decodificar(String cuerpo) {
    try {
      return jsonDecode(cuerpo);
    } on FormatException {
      throw const ApiException('La respuesta del servidor no es válida.');
    }
  }

  /// Libera la conexión HTTP. Se llama en el dispose de la pantalla.
  void cerrar() => _cliente.close();
}
