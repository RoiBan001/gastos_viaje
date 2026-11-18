import '../models/gasto.dart';
import '../models/tasas_cambio.dart';

/// Suma todos los gastos convertidos a la moneda base de [tasas] (pesos).
///
/// Devuelve null si algún gasto está en una moneda sin tasa, para no
/// mostrar un total incompleto como si fuera correcto.
double? totalEnPesos(List<Gasto> gastos, TasasCambio tasas) {
  var total = 0.0;
  for (final gasto in gastos) {
    final enPesos = tasas.aBase(gasto.monto, gasto.moneda);
    if (enPesos == null) {
      return null;
    }
    total += enPesos;
  }
  return total;
}

/// Suma los gastos agrupados por su moneda original, sin convertir.
/// Sirve para mostrar algo útil cuando la API no responde.
///
/// Ejemplo: {'USD': 120.5, 'COP': 30000}
Map<String, double> totalesPorMoneda(List<Gasto> gastos) {
  final totales = <String, double>{};
  for (final gasto in gastos) {
    totales[gasto.moneda] = (totales[gasto.moneda] ?? 0) + gasto.monto;
  }
  return totales;
}
