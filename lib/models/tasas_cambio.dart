/// Tasas de cambio que entrega la API, convertidas a un modelo de Dart.
///
/// Ejemplo de la respuesta JSON (resumida) de
/// https://open.er-api.com/v6/latest/COP :
///
/// ```json
/// {
///   "result": "success",
///   "base_code": "COP",
///   "time_last_update_unix": 1767225601,
///   "rates": { "COP": 1, "USD": 0.000245, "EUR": 0.000219 }
/// }
/// ```
///
/// Cada tasa dice cuántas unidades de esa moneda equivalen a 1 unidad de la
/// moneda [base]. Con base COP: 1 peso = 0.000245 dólares.
class TasasCambio {
  const TasasCambio({
    required this.base,
    required this.tasas,
    required this.actualizacion,
  });

  /// Moneda base de las tasas (en esta app siempre es 'COP').
  final String base;

  /// Código de moneda → cuántas unidades de ella equivalen a 1 [base].
  final Map<String, double> tasas;

  /// Momento en que la API actualizó las tasas por última vez.
  final DateTime actualizacion;

  factory TasasCambio.fromJson(Map<String, dynamic> json) {
    final tasasJson = json['rates'] as Map<String, dynamic>;
    final segundos = (json['time_last_update_unix'] as num).toInt();
    return TasasCambio(
      base: json['base_code'] as String,
      tasas: tasasJson.map(
        (codigo, valor) => MapEntry(codigo, (valor as num).toDouble()),
      ),
      actualizacion: DateTime.fromMillisecondsSinceEpoch(
        segundos * 1000,
        isUtc: true,
      ),
    );
  }

  /// Convierte [monto] expresado en [moneda] a la moneda [base].
  ///
  /// Ejemplo con base COP: 10 USD / 0.00025 = 40.000 COP.
  /// Devuelve null si la API no trajo tasa para esa moneda.
  double? aBase(double monto, String moneda) {
    if (moneda == base) {
      return monto;
    }
    final tasa = tasas[moneda];
    if (tasa == null || tasa == 0) {
      return null;
    }
    return monto / tasa;
  }
}
