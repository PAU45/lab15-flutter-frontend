import 'package:flutter/material.dart';
import 'pedido_service.dart';
import 'pedido.dart';
import 'mesa.dart';
import 'mesa_service.dart';
import 'usuario.dart';
import 'usuario_service.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final _service = PedidoService();
  late Future<List<Pedido>> _futurePedidos;

  @override
  void initState() {
    super.initState();
    _futurePedidos = _service.fetchPedidos();
  }

  void _refresh() {
    setState(() {
      _futurePedidos = _service.fetchPedidos();
    });
  }

  void _showAddDialog({Pedido? pedidoEdit}) {
    int? selectedMesaId = (pedidoEdit?.mesaId != null && pedidoEdit?.mesaId != 0) ? pedidoEdit!.mesaId : null;
    int? selectedUsuarioId = pedidoEdit?.usuarioId;
    String estado = pedidoEdit?.estado ?? 'pendiente';
    final totalCtrl = TextEditingController(text: pedidoEdit?.total != null ? pedidoEdit!.total.toString() : '');
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return FutureBuilder(
          future: Future.wait([
            MesaService().fetchMesas(),
            UsuarioService().fetchUsuarios(),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
            }
            final mesas = (snapshot.data![0] as List<Mesa>).where((m) => m.id != 0 && m.id != null).toList();
            final usuarios = snapshot.data![1] as List<Usuario>;
            // Si el valor inicial es 0 o no existe en la lista, ponerlo en null
            if (selectedMesaId == 0 || !mesas.any((m) => m.id == selectedMesaId)) {
              selectedMesaId = null;
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
                        pedidoEdit == null ? 'Nuevo Pedido' : 'Editar Pedido',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<int>(
                        value: selectedMesaId,
                        decoration: InputDecoration(
                          labelText: 'Mesa',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: const Color(0xFFF5F8FA),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Seleccione una mesa', style: TextStyle(color: Colors.grey)),
                          ),
                          ...mesas
                              .where((m) => m.id != null && m.id != 0)
                              .map((m) => DropdownMenuItem(
                                    value: m.id!,
                                    child: Text('Mesa #${m.numeroMesa} (${m.estado})'),
                                  ))
                              .toList(),
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedMesaId = val;
                          });
                        },
                        validator: (val) {
                          if (val == null) {
                            return 'Seleccione una mesa válida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        value: selectedUsuarioId,
                        decoration: InputDecoration(
                          labelText: 'Usuario',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: const Color(0xFFF5F8FA),
                        ),
                        items: usuarios
                            .where((u) => u.id != null)
                            .map((u) => DropdownMenuItem(
                                  value: u.id!,
                                  child: Text(u.nombre),
                                ))
                            .toList(),
                        onChanged: (val) {
                          selectedUsuarioId = val;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: estado,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: const Color(0xFFF5F8FA),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                          DropdownMenuItem(value: 'en_proceso', child: Text('En Proceso')),
                          DropdownMenuItem(value: 'servido', child: Text('Servido')),
                          DropdownMenuItem(value: 'pagado', child: Text('Pagado')),
                        ],
                        onChanged: (val) {
                          if (val != null) estado = val;
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
                              if (selectedMesaId == null || selectedUsuarioId == null || totalCtrl.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Todos los campos son obligatorios')),
                                );
                                return;
                              }
                              try {
                                final pedido = Pedido(
                                  id: pedidoEdit?.id,
                                  mesaId: selectedMesaId!,
                                  usuarioId: selectedUsuarioId!,
                                  estado: estado,
                                  total: double.tryParse(totalCtrl.text) ?? 0,
                                );
                                if (pedidoEdit == null) {
                                  await _service.createPedido(pedido);
                                } else {
                                  // Aquí deberías implementar updatePedido si lo tienes
                                }
                                Navigator.pop(ctx);
                                _refresh();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al guardar pedido: $e')),
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
        title: const Text('Pedidos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF5F8FA),
      body: FutureBuilder<List<Pedido>>(
        future: _futurePedidos,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: \\${snap.error}', style: TextStyle(color: Colors.red)));
          }
          final pedidos = snap.requireData;
          if (pedidos.isEmpty) {
            return const Center(child: Text('No hay pedidos.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final pedido = pedidos[i];
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
                        child: const Icon(Icons.receipt_long, color: Color(0xFF2196F3), size: 30),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pedido #${pedido.id ?? ''}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.table_bar, size: 18, color: Color(0xFF43A047)),
                                const SizedBox(width: 4),
                                Text('Mesa: ${pedido.mesaId}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.person, size: 18, color: Color(0xFF2196F3)),
                                const SizedBox(width: 4),
                                Text('Usuario: ${pedido.usuarioId}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _estadoColor(pedido.estado).withOpacity(0.13),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                pedido.estado[0].toUpperCase() + pedido.estado.substring(1).replaceAll('_', ' '),
                                style: TextStyle(fontSize: 13, color: _estadoColor(pedido.estado), fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: S/ ${pedido.total.toStringAsFixed(2)}',
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
                            onPressed: () => _showAddDialog(pedidoEdit: pedido),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFD32F2F)),
                            tooltip: 'Eliminar',
                            onPressed: () async {
                              if (pedido.id != null) {
                                await _service.deletePedido(pedido.id!);
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
        tooltip: 'Agregar Pedido',
      ),
    );

  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return const Color(0xFF2196F3);
      case 'en_proceso':
        return const Color(0xFFFFA000);
      case 'servido':
        return const Color(0xFF43A047);
      case 'pagado':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }
  }
