import 'package:flutter/material.dart';
import 'detalle_pedido.dart';
import 'detalle_pedido_service.dart';

class DetallePedidoScreen extends StatefulWidget {
  const DetallePedidoScreen({super.key});

  @override
  State<DetallePedidoScreen> createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  final _service = DetallePedidoService();
  late Future<List<DetallePedido>> _futureDetalles = Future.value([]);

  @override
  void initState() {
    super.initState();
    _futureDetalles = _service.fetchDetalles();
  }

  void _refresh() {
    setState(() {
      _futureDetalles = _service.fetchDetalles();
    });
  }

  void _showAddDialog({DetallePedido? detalleEdit}) {
    final pedidoIdCtrl = TextEditingController(text: detalleEdit?.pedidoId != null ? detalleEdit!.pedidoId.toString() : '');
    final platoIdCtrl = TextEditingController(text: detalleEdit?.platoId != null ? detalleEdit!.platoId.toString() : '');
    final cantidadCtrl = TextEditingController(text: detalleEdit?.cantidad != null ? detalleEdit!.cantidad.toString() : '');
    final precioUnitarioCtrl = TextEditingController(text: detalleEdit?.precioUnitario != null ? detalleEdit!.precioUnitario.toString() : '');
    DateTime? fechaSeleccionada;
    final fechaCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
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
                  detalleEdit == null ? 'Nuevo Detalle' : 'Editar Detalle',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: pedidoIdCtrl,
                  decoration: InputDecoration(
                    labelText: 'ID Pedido',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: platoIdCtrl,
                  decoration: InputDecoration(
                    labelText: 'ID Plato',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cantidadCtrl,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: precioUnitarioCtrl,
                  decoration: InputDecoration(
                    labelText: 'Precio Unitario',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: fechaCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Fecha (opcional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      fechaSeleccionada = picked;
                      fechaCtrl.text = picked.toIso8601String().split('T').first;
                    }
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
                        if (pedidoIdCtrl.text.isEmpty || platoIdCtrl.text.isEmpty || cantidadCtrl.text.isEmpty || precioUnitarioCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Todos los campos son obligatorios')),
                          );
                          return;
                        }
                        try {
                          final detalle = DetallePedido(
                            id: detalleEdit?.id,
                            pedidoId: int.tryParse(pedidoIdCtrl.text) ?? 1,
                            platoId: int.tryParse(platoIdCtrl.text) ?? 1,
                            cantidad: int.tryParse(cantidadCtrl.text) ?? 1,
                            precioUnitario: double.tryParse(precioUnitarioCtrl.text) ?? 0,
                          );
                          if (detalleEdit == null) {
                            await _service.createDetalle(detalle);
                          } else {
                            // Aquí podrías implementar updateDetalle si lo tienes
                          }
                          Navigator.pop(ctx);
                          _refresh();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar detalle: $e')),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Pedido', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF5F8FA),
      body: FutureBuilder<List<DetallePedido>>(
        future: _futureDetalles,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: \\${snap.error}', style: TextStyle(color: Colors.red)));
          }
          final detalles = snap.data ?? [];
          if (detalles.isEmpty) {
            return const Center(child: Text('No hay detalles.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: detalles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final detalle = detalles[i];
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
                        child: const Icon(Icons.fastfood, color: Color(0xFF2196F3), size: 30),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detalle #${detalle.id ?? ''}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.receipt_long, size: 18, color: Color(0xFF43A047)),
                                const SizedBox(width: 4),
                                Text('Pedido: ${detalle.pedidoId}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.fastfood, size: 18, color: Color(0xFF2196F3)),
                                const SizedBox(width: 4),
                                Text('Plato: ${detalle.platoId}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.people, size: 16, color: Color(0xFF43A047)),
                                const SizedBox(width: 4),
                                Text('Cantidad: ${detalle.cantidad}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Precio: S/ ${detalle.precioUnitario.toStringAsFixed(2)}',
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
                            onPressed: () => _showAddDialog(detalleEdit: detalle),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFD32F2F)),
                            tooltip: 'Eliminar',
                            onPressed: () async {
                              if (detalle.id != null) {
                                await _service.deleteDetalle(detalle.id!);
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
        tooltip: 'Agregar Detalle',
      ),
    );
  }
}
