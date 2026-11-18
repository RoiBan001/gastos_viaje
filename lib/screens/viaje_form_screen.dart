import 'package:flutter/material.dart';

import '../models/viaje.dart';
import '../services/base_datos.dart';
import '../utils/formato.dart';
import '../utils/validadores.dart';
import '../widgets/campo_fecha.dart';
import '../widgets/selector_moneda.dart';

/// Pantalla 2: formulario para crear o editar un viaje.
///
/// Si recibe un [viaje], lo edita. Si no, crea uno nuevo.
/// Al guardar, devuelve el viaje con `Navigator.pop`.
class ViajeFormScreen extends StatefulWidget {
  const ViajeFormScreen({super.key, this.viaje});

  final Viaje? viaje;

  @override
  State<ViajeFormScreen> createState() => _ViajeFormScreenState();
}

class _ViajeFormScreenState extends State<ViajeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _destinoCtrl;
  late final TextEditingController _presupuestoCtrl;
  late String _moneda;
  late DateTime _fechaInicio;
  bool _guardando = false;

  bool get _esEdicion => widget.viaje != null;

  @override
  void initState() {
    super.initState();
    final viaje = widget.viaje;
    _nombreCtrl = TextEditingController(text: viaje?.nombre ?? '');
    _destinoCtrl = TextEditingController(text: viaje?.destino ?? '');
    _presupuestoCtrl = TextEditingController(
      text: viaje == null ? '' : montoParaEditar(viaje.presupuestoCop),
    );
    _moneda = viaje?.moneda ?? 'USD';
    _fechaInicio = viaje?.fechaInicio ?? DateTime.now();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _destinoCtrl.dispose();
    _presupuestoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    // Ejecuta los validator de todos los campos; si alguno falla, no sigue
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    final viaje = Viaje(
      id: widget.viaje?.id,
      nombre: _nombreCtrl.text.trim(),
      destino: _destinoCtrl.text.trim(),
      moneda: _moneda,
      presupuestoCop: leerMonto(_presupuestoCtrl.text)!,
      fechaInicio: _fechaInicio,
    );

    try {
      final Viaje guardado;
      if (_esEdicion) {
        await BaseDatos.instancia.actualizarViaje(viaje);
        guardado = viaje;
      } else {
        guardado = await BaseDatos.instancia.insertarViaje(viaje);
      }
      if (!mounted) return;
      Navigator.pop(context, guardado);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar viaje' : 'Nuevo viaje')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del viaje',
                hintText: 'Ej: Vacaciones en Lima',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 40,
              validator: (valor) => validarObligatorio(valor, campo: 'El nombre'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _destinoCtrl,
              decoration: const InputDecoration(
                labelText: 'Destino',
                hintText: 'Ej: Lima, Perú',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 40,
              validator: (valor) =>
                  validarObligatorio(valor, campo: 'El destino'),
            ),
            const SizedBox(height: 8),
            SelectorMoneda(
              etiqueta: 'Moneda del destino',
              valor: _moneda,
              onChanged: (moneda) => setState(() => _moneda = moneda),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _presupuestoCtrl,
              decoration: const InputDecoration(
                labelText: 'Presupuesto total en pesos (COP)',
                hintText: 'Ej: 3000000',
                helperText: 'Escríbelo sin puntos de miles',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.savings),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: validarMonto,
            ),
            const SizedBox(height: 16),
            CampoFecha(
              etiqueta: 'Fecha de inicio',
              fecha: _fechaInicio,
              onChanged: (fecha) => setState(() => _fechaInicio = fecha),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              // Deshabilitado mientras guarda, para evitar doble toque
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save),
              label: Text(_esEdicion ? 'Guardar cambios' : 'Crear viaje'),
            ),
          ],
        ),
      ),
    );
  }
}
