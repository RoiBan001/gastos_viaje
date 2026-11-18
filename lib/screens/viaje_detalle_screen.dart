import 'package:flutter/material.dart';

import '../models/estado_carga.dart';
import '../models/gasto.dart';
import '../models/tasas_cambio.dart';
import '../models/viaje.dart';
import '../services/base_datos.dart';
import '../services/tasas_api_service.dart';
import '../utils/formato.dart';
import '../utils/monedas.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/gasto_tile.dart';
import '../widgets/resumen_pesos.dart';
import 'gasto_form_screen.dart';
import 'viaje_form_screen.dart';

/// Pantalla 3: detalle de un viaje.
///
/// Junta las dos fuentes de datos de la app:
/// - los gastos guardados en SQLite, y
/// - las tasas de cambio que llegan de la API, para convertirlos a pesos.
class ViajeDetalleScreen extends StatefulWidget {
  const ViajeDetalleScreen({super.key, required this.viaje});

  final Viaje viaje;

  @override
  State<ViajeDetalleScreen> createState() => _ViajeDetalleScreenState();
}

class _ViajeDetalleScreenState extends State<ViajeDetalleScreen> {
  final _baseDatos = BaseDatos.instancia;
  final _api = TasasApiService();

  late Viaje _viaje;
  List<Gasto> _gastos = [];
  bool _cargandoGastos = true;

  // Estado de la consulta a la API
  EstadoCarga _estadoTasas = EstadoCarga.cargando;
  TasasCambio? _tasas;
  String? _errorTasas;

  @override
  void initState() {
    super.initState();
    // Copia local: si el usuario edita el viaje, se reemplaza
    _viaje = widget.viaje;
    _cargarGastos();
    _cargarTasas();
  }

  @override
  void dispose() {
    _api.cerrar();
    super.dispose();
  }

  // ------------------------------------------------------------ Carga

  Future<void> _cargarGastos() async {
    final gastos = await _baseDatos.obtenerGastos(_viaje.id!);
    if (!mounted) return;
    setState(() {
      _gastos = gastos;
      _cargandoGastos = false;
    });
  }

  /// Pide las tasas con base COP: con una sola consulta se pueden
  /// convertir a pesos gastos en cualquier moneda.
  Future<void> _cargarTasas() async {
    try {
      final tasas = await _api.obtenerTasas('COP');
      if (!mounted) return;
      setState(() {
        _tasas = tasas;
        _estadoTasas = EstadoCarga.exito;
      });
    } on ApiException catch (e) {
      // Errores esperados: sin conexión, tiempo agotado, error del servidor
      _mostrarErrorTasas(e.mensaje);
    } catch (_) {
      // Cualquier otra cosa, por ejemplo un JSON con otra estructura
      _mostrarErrorTasas('Respuesta inesperada del servidor.');
    }
  }

  void _mostrarErrorTasas(String mensaje) {
    if (!mounted) return;
    setState(() {
      _errorTasas = mensaje;
      _estadoTasas = EstadoCarga.error;
    });
  }

  void _reintentarTasas() {
    setState(() {
      _estadoTasas = EstadoCarga.cargando;
      _errorTasas = null;
    });
    _cargarTasas();
  }

  /// Se ejecuta al deslizar la lista hacia abajo.
  Future<void> _recargarTodo() async {
    await Future.wait([_cargarGastos(), _cargarTasas()]);
  }

  // ------------------------------------------------------------ Acciones

  Future<void> _abrirFormularioGasto([Gasto? gasto]) async {
    final guardado = await Navigator.push<Gasto>(
      context,
      MaterialPageRoute(
        builder: (context) => GastoFormScreen(viaje: _viaje, gasto: gasto),
      ),
    );
    if (guardado != null) {
      _cargarGastos();
    }
  }

  Future<void> _editarViaje() async {
    final editado = await Navigator.push<Viaje>(
      context,
      MaterialPageRoute(builder: (context) => ViajeFormScreen(viaje: _viaje)),
    );
    if (editado != null && mounted) {
      setState(() => _viaje = editado);
    }
  }

  Future<void> _eliminarViaje() async {
    final confirmado = await _confirmar(
      titulo: '¿Eliminar viaje?',
      mensaje:
          'Se borrarán "${_viaje.nombre}" y sus ${_gastos.length} gastos. '
          'No se puede deshacer.',
    );
    if (!confirmado) return;
    await _baseDatos.eliminarViaje(_viaje.id!);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _eliminarGasto(Gasto gasto) async {
    // El Dismissible exige quitar el elemento de la lista de inmediato
    setState(() => _gastos.remove(gasto));
    await _baseDatos.eliminarGasto(gasto.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${gasto.descripcion}" eliminado')),
    );
  }

  /// Muestra un diálogo de confirmación. Devuelve true si el usuario acepta.
  Future<bool> _confirmar({
    required String titulo,
    required String mensaje,
  }) async {
    final respuesta = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    // Si el usuario cierra el diálogo tocando afuera, llega null
    return respuesta ?? false;
  }

  // ------------------------------------------------------------ Interfaz

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_viaje.nombre),
        actions: [
          IconButton(
            tooltip: 'Editar viaje',
            icon: const Icon(Icons.edit),
            onPressed: _editarViaje,
          ),
          IconButton(
            tooltip: 'Eliminar viaje',
            icon: const Icon(Icons.delete_outline),
            onPressed: _eliminarViaje,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormularioGasto(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar gasto'),
      ),
      body: RefreshIndicator(
        onRefresh: _recargarTodo,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
          children: [
            _encabezado(),
            ResumenPesos(
              estado: _estadoTasas,
              viaje: _viaje,
              gastos: _gastos,
              tasas: _tasas,
              error: _errorTasas,
              onReintentar: _reintentarTasas,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Gastos (${_gastos.length})',
                style: tema.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            if (_cargandoGastos)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_gastos.isEmpty)
              const EstadoVacio(
                icono: Icons.receipt_long,
                titulo: 'Sin gastos todavía',
                mensaje: 'Toca "Agregar gasto" para registrar el primero.',
              )
            else
              for (final gasto in _gastos) _gastoDeslizable(gasto),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.place),
        title: Text(_viaje.destino),
        subtitle: Text(
          'Desde el ${formatearFecha(_viaje.fechaInicio)} · '
          '${_viaje.moneda} (${nombreMoneda(_viaje.moneda)})',
        ),
      ),
    );
  }

  /// Un gasto que se puede borrar deslizándolo hacia la izquierda.
  Widget _gastoDeslizable(Gasto gasto) {
    final colores = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(gasto.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colores.error,
        child: Icon(Icons.delete, color: colores.onError),
      ),
      confirmDismiss: (direction) => _confirmar(
        titulo: '¿Eliminar gasto?',
        mensaje: 'Se eliminará "${gasto.descripcion}".',
      ),
      onDismissed: (direction) => _eliminarGasto(gasto),
      child: Card(
        child: GastoTile(
          gasto: gasto,
          tasas: _tasas,
          onTap: () => _abrirFormularioGasto(gasto),
        ),
      ),
    );
  }
}
