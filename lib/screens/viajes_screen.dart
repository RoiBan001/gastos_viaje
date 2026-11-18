import 'package:flutter/material.dart';

import '../models/viaje.dart';
import '../services/base_datos.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/viaje_card.dart';
import 'viaje_detalle_screen.dart';
import 'viaje_form_screen.dart';

/// Pantalla 1: lista de viajes guardados en el dispositivo.
class ViajesScreen extends StatefulWidget {
  const ViajesScreen({super.key});

  @override
  State<ViajesScreen> createState() => _ViajesScreenState();
}

class _ViajesScreenState extends State<ViajesScreen> {
  final _baseDatos = BaseDatos.instancia;

  List<Viaje> _viajes = [];
  Map<int, int> _cantidadGastos = {};
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarViajes();
  }

  Future<void> _cargarViajes() async {
    try {
      final viajes = await _baseDatos.obtenerViajes();
      final cantidades = await _baseDatos.contarGastosPorViaje();
      // Si el usuario salió de la pantalla mientras esperábamos,
      // no se puede llamar a setState.
      if (!mounted) return;
      setState(() {
        _viajes = viajes;
        _cantidadGastos = cantidades;
        _cargando = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = 'No se pudieron leer los viajes guardados.\n$e';
      });
    }
  }

  Future<void> _crearViaje() async {
    // El formulario devuelve el viaje creado, o null si el usuario canceló
    final creado = await Navigator.push<Viaje>(
      context,
      MaterialPageRoute(builder: (context) => const ViajeFormScreen()),
    );
    if (creado != null) {
      _cargarViajes();
    }
  }

  Future<void> _abrirViaje(Viaje viaje) async {
    // El viaje seleccionado viaja a la pantalla de detalle
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViajeDetalleScreen(viaje: viaje),
      ),
    );
    // Al volver se recarga: el viaje pudo editarse, borrarse o tener
    // gastos nuevos.
    _cargarViajes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis viajes')),
      body: _construirCuerpo(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearViaje,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo viaje'),
      ),
    );
  }

  Widget _construirCuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _error;
    if (error != null) {
      return EstadoVacio(
        icono: Icons.error_outline,
        titulo: 'Algo salió mal',
        mensaje: error,
      );
    }
    if (_viajes.isEmpty) {
      return const EstadoVacio(
        icono: Icons.luggage,
        titulo: 'Aún no tienes viajes',
        mensaje: 'Toca "Nuevo viaje" para registrar el primero.',
      );
    }
    return ListView.builder(
      // Espacio abajo para que el botón flotante no tape la última tarjeta
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      itemCount: _viajes.length,
      itemBuilder: (context, index) {
        final viaje = _viajes[index];
        return ViajeCard(
          viaje: viaje,
          cantidadGastos: _cantidadGastos[viaje.id] ?? 0,
          onTap: () => _abrirViaje(viaje),
        );
      },
    );
  }
}
