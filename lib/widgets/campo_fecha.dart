import 'package:flutter/material.dart';

import '../utils/formato.dart';

/// Campo que muestra una fecha y abre el calendario al tocarlo.
class CampoFecha extends StatelessWidget {
  const CampoFecha({
    super.key,
    required this.etiqueta,
    required this.fecha,
    required this.onChanged,
  });

  final String etiqueta;
  final DateTime fecha;
  final ValueChanged<DateTime> onChanged;

  Future<void> _elegirFecha(BuildContext context) async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: etiqueta,
    );
    // Si el usuario cancela, showDatePicker devuelve null
    if (elegida != null) {
      onChanged(elegida);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _elegirFecha(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(formatearFecha(fecha)),
      ),
    );
  }
}
