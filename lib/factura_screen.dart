import 'package:flutter/material.dart';
import 'factura.dart';
import 'pedido.dart';
import 'pedido_service.dart';
import 'factura_service.dart';

class FacturaScreen extends StatefulWidget {
  const FacturaScreen({super.key});

  @override
  State<FacturaScreen> createState() => _FacturaScreenState();
}

class _FacturaScreenState extends State<FacturaScreen> {
  String _formatFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
  final _service = FacturaService();
  late Future<List<Factura>> _futureFacturas = Future.value([]);

  @override
  void initState() {
    super.initState();
    _futureFacturas = _service.fetchFacturas();
  }

  void _refresh() {
    setState(() {
      _futureFacturas = _service.fetchFacturas();
    });
  }
  void _showAddDialog({Factura? facturaEdit}) {
    int? selectedPedidoId = facturaEdit?.pedidoId;
    final totalCtrl = TextEditingController(text: facturaEdit?.total != null ? facturaEdit!.total.toString() : '');
    String? selectedMetodoPago = facturaEdit?.metodoPago;
    DateTime? fechaSeleccionada = facturaEdit?.fecha;
    final fechaCtrl = TextEditingController(text: facturaEdit?.fecha != null ? facturaEdit!.fecha.toIso8601String().split('T').first : '');
    final metodosPago = ['Efectivo', 'Tarjeta', 'Transferencia', 'Otro'];
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return FutureBuilder<List<Pedido>>(
          future: PedidoService().fetchPedidos(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
            }
            final pedidos = snapshot.data!;
            if (selectedPedidoId != null && !pedidos.any((p) => p.id == selectedPedidoId)) {
              selectedPedidoId = null;
            }
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Center(
                child: Container(
                  width: 370,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        facturaEdit == null ? 'Nueva Factura' : 'Editar Factura',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<int>(
                        value: selectedPedidoId,
                        decoration: InputDecoration(
                          labelText: 'ID Pedido',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: const Color(0xFFF5F8FA),
                        ),
                        items: pedidos
                            .where((p) => p.id != null)
                            .map((p) => DropdownMenuItem(
                                  value: p.id!,
                                  child: Text('Pedido #${p.id} - Mesa ${p.mesaId}'),
                                ))
                            .toList(),
                        onChanged: (val) {
                          selectedPedidoId = val;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: fechaCtrl,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Fecha',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: const Color(0xFFF5F8FA),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: fechaSeleccionada ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            fechaSeleccionada = picked;
                            fechaCtrl.text = picked.toIso8601String().split('T').first;
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: totalCtrl,
                        decoration: InputDecoration(
                          labelText: 'Total',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: const Color(0xFFF5F8FA),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedMetodoPago,
                        decoration: InputDecoration(
                          labelText: 'Método de Pago',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: const Color(0xFFF5F8FA),
                        ),
                        items: metodosPago
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m),
                                ))
                            .toList(),
                        onChanged: (val) {
                          selectedMetodoPago = val;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF2196F3),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (selectedPedidoId == null || fechaCtrl.text.isEmpty || totalCtrl.text.isEmpty || (selectedMetodoPago == null || (selectedMetodoPago?.isEmpty ?? true))) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Todos los campos son obligatorios')),
                                );
                                return;
                              }
                              try {
                                final factura = Factura(
                                  id: facturaEdit?.id,
                                  pedidoId: selectedPedidoId!,
                                  fecha: fechaSeleccionada ?? DateTime.now(),
                                  total: double.tryParse(totalCtrl.text) ?? 0,
                                  metodoPago: selectedMetodoPago!,
                                );
                                if (facturaEdit == null) {
                                  await _service.createFactura(factura);
                                } else {
                                  await _service.updateFactura(factura);
                                }
                                Navigator.pop(ctx);
                                _refresh();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al guardar factura: $e')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF43A047),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              elevation: 0,
                            ),
                            child: const Text('Guardar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF5F8FA),
      body: FutureBuilder<List<Factura>>(
        future: _futureFacturas,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: \\${snap.error}', style: TextStyle(color: Colors.red)));
          }
          final facturas = snap.data ?? [];
          if (facturas.isEmpty) {
            return const Center(child: Text('No hay facturas.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: facturas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final factura = facturas[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 3,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.request_quote, color: Color(0xFF2196F3), size: 30),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Factura #${factura.id ?? ''}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.receipt_long, size: 18, color: Color(0xFF43A047)),
                                const SizedBox(width: 4),
                                Text('Pedido: ${factura.pedidoId}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Color(0xFF2196F3)),
                                const SizedBox(width: 4),
                                Text('Fecha: ${_formatFecha(factura.fecha)}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.payments, size: 18, color: Color(0xFF43A047)),
                                const SizedBox(width: 4),
                                Text('Pago: ${factura.metodoPago}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: S/ ${factura.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 15, color: Color(0xFF43A047), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
                            tooltip: 'Editar',
                            onPressed: () => _showAddDialog(facturaEdit: factura),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFD32F2F)),
                            tooltip: 'Eliminar',
                            onPressed: () async {
                              if (factura.id != null) {
                                await _service.deleteFactura(factura.id!);
                                _refresh();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF43A047),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Agregar Factura',
      ),
    );
  }
}
