/// Una moneda que el usuario puede elegir.
class Moneda {
  const Moneda(this.codigo, this.nombre);

  /// Código ISO 4217, el mismo que usa la API (por ejemplo 'USD').
  final String codigo;
  final String nombre;
}

/// Monedas de los destinos más comunes para viajeros desde Colombia.
/// Todas están soportadas por la API de tasas de cambio.
const List<Moneda> monedas = [
  Moneda('COP', 'Peso colombiano'),
  Moneda('USD', 'Dólar estadounidense'),
  Moneda('EUR', 'Euro'),
  Moneda('MXN', 'Peso mexicano'),
  Moneda('PEN', 'Sol peruano'),
  Moneda('ARS', 'Peso argentino'),
  Moneda('BRL', 'Real brasileño'),
  Moneda('CLP', 'Peso chileno'),
  Moneda('DOP', 'Peso dominicano'),
  Moneda('CRC', 'Colón costarricense'),
  Moneda('GBP', 'Libra esterlina'),
  Moneda('CAD', 'Dólar canadiense'),
  Moneda('CHF', 'Franco suizo'),
  Moneda('JPY', 'Yen japonés'),
];

/// Nombre de la moneda a partir de su código. Si no está en la lista,
/// devuelve el mismo código.
String nombreMoneda(String codigo) {
  for (final moneda in monedas) {
    if (moneda.codigo == codigo) {
      return moneda.nombre;
    }
  }
  return codigo;
}
