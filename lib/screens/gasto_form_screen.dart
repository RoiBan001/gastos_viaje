import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../models/gasto.dart';
import '../models/viaje.dart';
import '../services/base_datos.dart';
import '../utils/formato.dart';
import '../utils/validadores.dart';
import '../widgets/campo_fecha.dart';
import '../widgets/selector_moneda.dart';

/// Pantalla 4: formulario para agregar o editar un gasto de un [viaje].
///
/// Si recibe un [gasto], lo edita. Si no, crea uno nuevo.
/// Al guardar, devuelve el gasto con `Navigator.pop`.
class GastoFormScreen extends StatefulWidget {
  const GastoFormScreen({super.key, required this.viaje, this.gasto});

  final Viaje viaje;
  final Gasto? gasto;

  @override
  State<GastoFormScreen> createState() => _GastoFormScreenState();
}

class _GastoFormScreenState extends State<GastoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _montoCtrl;
  late String _moneda;
  late Categoria _categoria;
  late DateTime _fecha;
  bool _guardando = false;

  bool get _esEdicion => widget.gasto != null;

  @override
  void initState() {
    super.initState();
    final gasto = widget.gasto;
    _descripcionCtrl = TextEditingController(text: gasto?.descripcion ?? '');
    _montoCtrl = TextEditingController(
      text: gasto == null ? '' : montoParaEditar(gasto.monto),
    );
    // Un gasto nuevo usa por defecto la moneda del destino del viaje
    _moneda = gasto?.moneda ?? widget.viaje.moneda;
    _categoria = gasto?.categoria ?? Categoria.comida;
    _fecha = gasto?.fecha ?? DateTime.now();
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    final gasto = Gasto(
      id: widget.gasto?.id,
      viajeId: widget.viaje.id!,
      descripcion: _descripcionCtrl.text.trim(),
      monto: leerMonto(_montoCtrl.text)!,
      moneda: _moneda,
      categoria: _categoria,
      fecha: _fecha,
    );

    try {
      final Gasto guardado;
      if (_esEdicion) {
        await BaseDatos.instancia.actualizarGasto(gasto);
        guardado = gasto;
      } else {
        guardado = await BaseDatos.instancia.insertarGasto(gasto);
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
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar gasto' : 'Nuevo gasto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Viaje: ${widget.viaje.nombre}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej: Almuerzo en el centro',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 50,
              validator: (valor) =>
                  validarObligatorio(valor, campo: 'La descripción'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _montoCtrl,
              decoration: const InputDecoration(
                labelText: 'Monto',
                hintText: 'Ej: 25,50',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: validarMonto,
            ),
            const SizedBox(height: 16),
            SelectorMoneda(
              etiqueta: 'Moneda en que pagaste',
              valor: _moneda,
              onChanged: (moneda) => setState(() => _moneda = moneda),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Categoria>(
              initialValue: _categoria,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: [
                for (final categoria in Categoria.values)
                  DropdownMenuItem(
                    value: categoria,
                    child: Row(
                      children: [
                        Icon(categoria.icono, size: 20),
                        const SizedBox(width: 8),
                        Text(categoria.etiqueta),
                      ],
                    ),
                  ),
              ],
              onChanged: (categoria) {
                if (categoria != null) {
                  setState(() => _categoria = categoria);
                }
              },
            ),
            const SizedBox(height: 16),
            CampoFecha(
              etiqueta: 'Fecha del gasto',
              fecha: _fecha,
              onChanged: (fecha) => setState(() => _fecha = fecha),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save),
              label: Text(_esEdicion ? 'Guardar cambios' : 'Agregar gasto'),
            ),
          ],
        ),
      ),
    );
  }
}
