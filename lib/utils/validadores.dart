// Validadores para los campos de los formularios.
//
// Cada uno devuelve null si el valor es válido, o el mensaje de error que
// el TextFormField muestra debajo del campo.

/// El campo no puede estar vacío ni tener solo espacios.
String? validarObligatorio(String? valor, {String campo = 'Este campo'}) {
  if (valor == null || valor.trim().isEmpty) {
    return '$campo es obligatorio';
  }
  return null;
}

/// Convierte el texto de un monto en número. Acepta coma o punto como
/// separador decimal ('25,5' y '25.5'). Devuelve null si no es un número.
double? leerMonto(String? texto) {
  if (texto == null) {
    return null;
  }
  return double.tryParse(texto.trim().replaceAll(',', '.'));
}

/// El monto debe ser un número mayor que cero.
String? validarMonto(String? valor) {
  if (valor == null || valor.trim().isEmpty) {
    return 'Ingresa un monto';
  }
  final monto = leerMonto(valor);
  if (monto == null) {
    return 'Escribe solo números, sin puntos de miles (ej: 25,50)';
  }
  if (monto <= 0) {
    return 'El monto debe ser mayor que cero';
  }
  if (monto > 1000000000000) {
    return 'El monto es demasiado grande';
  }
  return null;
}
