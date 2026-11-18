import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/viajes_screen.dart';

void main() {
  runApp(const GastosViajeApp());
}

class GastosViajeApp extends StatelessWidget {
  const GastosViajeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gastos de Viaje',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00897B)),
      ),
      // Español para el calendario y los textos propios de Flutter
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const ViajesScreen(),
    );
  }
}
