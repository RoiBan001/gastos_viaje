import 'package:flutter/material.dart';

import '../models/viaje.dart';
import '../utils/formato.dart';

/// Tarjeta de un viaje en la lista de la pantalla principal.
class ViajeCard extends StatelessWidget {
  const ViajeCard({
    super.key,
    required this.viaje,
    required this.cantidadGastos,
    required this.onTap,
  });

  final Viaje viaje;
  final int cantidadGastos;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colores.primaryContainer,
          foregroundColor: colores.onPrimaryContainer,
          child: const Icon(Icons.flight_takeoff),
        ),
        title: Text(
          viaje.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${viaje.destino} · ${formatearFecha(viaje.fechaInicio)}\n'
          'Presupuesto: ${formatearPesos(viaje.presupuestoCop)}',
        ),
        isThreeLine: true,
        // El Badge muestra cuántos gastos tiene el viaje
        trailing: Badge(
          isLabelVisible: cantidadGastos > 0,
          label: Text('$cantidadGastos'),
          child: Chip(label: Text(viaje.moneda)),
        ),
      ),
    );
  }
}
