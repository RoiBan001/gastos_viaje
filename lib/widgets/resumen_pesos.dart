import 'package:flutter/material.dart';

import '../models/estado_carga.dart';
import '../models/gasto.dart';
import '../models/tasas_cambio.dart';
import '../models/viaje.dart';
import '../utils/calculos.dart';
import '../utils/formato.dart';

/// Tarjeta con el total gastado en pesos y el avance del presupuesto.
///
/// Muestra un contenido distinto para cada estado de la consulta a la API:
/// cargando, éxito o error (con botón para reintentar).
class ResumenPesos extends StatelessWidget {
  const ResumenPesos({
    super.key,
    required this.estado,
    required this.viaje,
    required this.gastos,
    required this.onReintentar,
    this.tasas,
    this.error,
  });

  final EstadoCarga estado;
  final Viaje viaje;
  final List<Gasto> gastos;
  final VoidCallback onReintentar;

  /// Solo tiene valor cuando [estado] es [EstadoCarga.exito].
  final TasasCambio? tasas;

  /// Solo tiene valor cuando [estado] es [EstadoCarga.error].
  final String? error;

  @override
  Widget build(BuildContext context) {
    final Widget contenido;
    switch (estado) {
      case EstadoCarga.cargando:
        contenido = _cargando();
      case EstadoCarga.error:
        contenido = _error(context);
      case EstadoCarga.exito:
        contenido = _exito(context, tasas!);
    }
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: contenido),
    );
  }

  Widget _cargando() {
    return const Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        SizedBox(width: 16),
        Expanded(child: Text('Consultando tasas de cambio...')),
      ],
    );
  }

  Widget _error(BuildContext context) {
    final tema = Theme.of(context);
    final totales = totalesPorMoneda(gastos);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cloud_off, color: tema.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No se pudo convertir a pesos',
                style: tema.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(error ?? 'Error desconocido.'),
        // Sin conexión la app sigue siendo útil: muestra los totales
        // en la moneda original, que están guardados en el dispositivo.
        if (totales.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Mientras tanto, tus gastos en su moneda original:'),
          for (final total in totales.entries)
            Text('• ${formatearMoneda(total.value, total.key)}'),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onReintentar,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ],
    );
  }

  Widget _exito(BuildContext context, TasasCambio tasas) {
    final tema = Theme.of(context);
    final total = totalEnPesos(gastos, tasas);
    final presupuesto = viaje.presupuestoCop;
    final unaMonedaEnPesos = tasas.aBase(1, viaje.moneda);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total gastado en pesos', style: tema.textTheme.labelLarge),
        if (total == null)
          const Text('Hay gastos en una moneda sin tasa de cambio.')
        else ...[
          Text(
            formatearPesos(total),
            style: tema.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _barraPresupuesto(tema, total, presupuesto),
        ],
        const Divider(height: 24),
        if (viaje.moneda != 'COP' && unaMonedaEnPesos != null)
          Text('1 ${viaje.moneda} = ${formatearPesos(unaMonedaEnPesos)}'),
        Text(
          'Tasas actualizadas el '
          '${formatearFecha(tasas.actualizacion.toLocal())}',
          style: tema.textTheme.bodySmall,
        ),
        // Atribución que exige ExchangeRate-API en sus condiciones de uso
        Text(
          'Tasas por ExchangeRate-API (exchangerate-api.com)',
          style: tema.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _barraPresupuesto(ThemeData tema, double total, double presupuesto) {
    final excedido = total > presupuesto;
    // Fracción del presupuesto usada, entre 0 y 1, para la barra
    final double avance = presupuesto > 0
        ? (total / presupuesto).clamp(0.0, 1.0).toDouble()
        : 1.0;
    final mensaje = excedido
        ? 'Te pasaste por ${formatearPesos(total - presupuesto)}'
        : 'Te quedan ${formatearPesos(presupuesto - total)} '
              'de ${formatearPesos(presupuesto)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: avance,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
          color: excedido ? tema.colorScheme.error : null,
        ),
        const SizedBox(height: 8),
        Text(
          mensaje,
          style: TextStyle(
            color: excedido ? tema.colorScheme.error : null,
            fontWeight: excedido ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }
}
