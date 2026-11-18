import 'package:flutter/material.dart';

/// Categorías posibles de un gasto.
///
/// En la base de datos se guarda el [name] del valor (por ejemplo 'comida')
/// y en pantalla se muestran la [etiqueta] y el [icono].
enum Categoria {
  comida('Comida', Icons.restaurant),
  transporte('Transporte', Icons.directions_bus),
  alojamiento('Alojamiento', Icons.hotel),
  entretenimiento('Entretenimiento', Icons.attractions),
  compras('Compras', Icons.shopping_bag),
  otros('Otros', Icons.more_horiz);

  const Categoria(this.etiqueta, this.icono);

  final String etiqueta;
  final IconData icono;

  /// Convierte el texto guardado en la base de datos en una [Categoria].
  /// Si el texto no corresponde a ninguna, devuelve [Categoria.otros].
  static Categoria desdeNombre(String nombre) {
    return Categoria.values.firstWhere(
      (categoria) => categoria.name == nombre,
      orElse: () => Categoria.otros,
    );
  }
}
