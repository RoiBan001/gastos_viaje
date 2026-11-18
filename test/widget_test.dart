import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_viaje/models/categoria.dart';
import 'package:gastos_viaje/models/gasto.dart';
import 'package:gastos_viaje/widgets/estado_vacio.dart';
import 'package:gastos_viaje/widgets/gasto_tile.dart';

/// Pruebas de los widgets reutilizables. No se prueba la app completa
/// porque SQLite no está disponible en el entorno de pruebas.
void main() {
  testWidgets('EstadoVacio muestra el ícono, el título y el mensaje', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EstadoVacio(
            icono: Icons.luggage,
            titulo: 'Aún no tienes viajes',
            mensaje: 'Toca "Nuevo viaje" para registrar el primero.',
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.luggage), findsOneWidget);
    expect(find.text('Aún no tienes viajes'), findsOneWidget);
  });

  testWidgets('GastoTile muestra descripción, categoría y monto', (
    tester,
  ) async {
    final gasto = Gasto(
      id: 1,
      viajeId: 1,
      descripcion: 'Taxi al hotel',
      monto: 25.5,
      moneda: 'USD',
      categoria: Categoria.transporte,
      fecha: DateTime(2026, 1, 10),
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: GastoTile(gasto: gasto))),
    );

    expect(find.text('Taxi al hotel'), findsOneWidget);
    expect(find.text('Transporte · 10/01/2026'), findsOneWidget);
    expect(find.text('25,50 USD'), findsOneWidget);
    expect(find.byIcon(Icons.directions_bus), findsOneWidget);
  });
}
