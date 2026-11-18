import 'package:flutter/material.dart';

import '../utils/monedas.dart';

/// Lista desplegable para elegir una moneda. Se usa en los formularios de
/// viaje y de gasto.
class SelectorMoneda extends StatelessWidget {
  const SelectorMoneda({
    super.key,
    required this.valor,
    required this.onChanged,
    this.etiqueta = 'Moneda',
  });

  /// Código de la moneda seleccionada al abrir el formulario.
  final String valor;
  final ValueChanged<String> onChanged;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: etiqueta,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.currency_exchange),
      ),
      items: [
        for (final moneda in monedas)
          DropdownMenuItem(
            value: moneda.codigo,
            child: Text('${moneda.codigo} · ${moneda.nombre}'),
          ),
      ],
      onChanged: (nuevaMoneda) {
        if (nuevaMoneda != null) {
          onChanged(nuevaMoneda);
        }
      },
    );
  }
}
