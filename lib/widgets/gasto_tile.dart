import 'package:flutter/material.dart';

import '../models/gasto.dart';
import '../models/tasas_cambio.dart';
import '../utils/formato.dart';

/// Fila de un gasto: categoría, descripción, fecha y monto.
///
/// Si hay [tasas] y el gasto no está en pesos, muestra también su
/// equivalente aproximado en pesos.
class GastoTile extends StatelessWidget {
  const GastoTile({super.key, required this.gasto, this.tasas, this.onTap});

  final Gasto gasto;
  final TasasCambio? tasas;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tasasActuales = tasas;
    double? enPesos;
    if (tasasActuales != null && gasto.moneda != 'COP') {
      enPesos = tasasActuales.aBase(gasto.monto, gasto.moneda);
    }

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Icon(gasto.categoria.icono)),
      title: Text(gasto.descripcion),
      subtitle: Text(
        '${gasto.categoria.etiqueta} · ${formatearFecha(gasto.fecha)}',
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatearMoneda(gasto.monto, gasto.moneda),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (enPesos != null)
            Text(
              '≈ ${formatearPesos(enPesos)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
