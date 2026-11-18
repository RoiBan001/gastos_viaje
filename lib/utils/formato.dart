// Funciones para mostrar números y fechas con el formato colombiano.

/// Escribe un número con punto para los miles y coma para los decimales.
///
/// `formatearNumero(1234567)` → '1.234.567'
/// `formatearNumero(1234.5, decimales: 2)` → '1.234,50'
String formatearNumero(double valor, {int decimales = 0}) {
  final partes = valor.abs().toStringAsFixed(decimales).split('.');
  final entero = partes[0];

  final buffer = StringBuffer();
  for (var i = 0; i < entero.length; i++) {
    // Pone un punto cada tres cifras, contando desde la derecha
    if (i > 0 && (entero.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(entero[i]);
  }

  var resultado = buffer.toString();
  if (decimales > 0) {
    resultado = '$resultado,${partes[1]}';
  }
  return valor < 0 ? '-$resultado' : resultado;
}

/// Pesos colombianos, sin decimales: '$ 1.234.567'.
String formatearPesos(double valor) => '\$ ${formatearNumero(valor)}';

/// Un monto en cualquier moneda. Los pesos van sin decimales y las demás
/// monedas con dos decimales y su código: '25,50 USD'.
String formatearMoneda(double valor, String codigo) {
  if (codigo == 'COP') {
    return formatearPesos(valor);
  }
  return '${formatearNumero(valor, decimales: 2)} $codigo';
}

/// Fecha en formato dd/mm/aaaa.
String formatearFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}

/// Texto para poner un monto en un campo de edición:
/// 3000000.0 → '3000000' y 25.5 → '25.5'.
String montoParaEditar(double valor) {
  if (valor == valor.roundToDouble()) {
    return valor.toStringAsFixed(0);
  }
  return valor.toString();
}
