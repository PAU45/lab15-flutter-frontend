import 'package:flutter/material.dart';
import 'mesa_service.dart';
import 'mesa.dart';

class MesasScreen extends StatefulWidget {
  const MesasScreen({super.key});

  @override
  State<MesasScreen> createState() => _MesasScreenState();
}

class _MesasScreenState extends State<MesasScreen> {
  final _service = MesaService();
  late Future<List<Mesa>> _futureMesas;

  @override
  void initState() {
    super.initState();
    _futureMesas = _service.fetchMesas();
  }

  void _refresh() {
    setState(() {
      _futureMesas = _service.fetchMesas();
    });
  }

  void _showAddDialog({Mesa? mesaEdit}) {
    final numeroMesaCtrl = TextEditingController(text: mesaEdit?.numeroMesa != null ? mesaEdit!.numeroMesa.toString() : '');
    final capacidadCtrl = TextEditingController(text: mesaEdit?.capacidad != null ? mesaEdit!.capacidad.toString() : '');
    String estado = mesaEdit?.estado ?? 'disponible';
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
                  mesaEdit == null ? 'Nueva Mesa' : 'Editar Mesa',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: numeroMesaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Número de Mesa',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: capacidadCtrl,
                  decoration: InputDecoration(
                    labelText: 'Capacidad',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
                  keyboardType: TextInputType.number,
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
                    DropdownMenuItem(value: 'disponible', child: Text('Disponible')),
                    DropdownMenuItem(value: 'ocupada', child: Text('Ocupada')),
                    DropdownMenuItem(value: 'reservada', child: Text('Reservada')),
                    DropdownMenuItem(value: 'mantenimiento', child: Text('Mantenimiento')),
                  ],
                  onChanged: (val) {
                    if (val != null) estado = val;
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
                        if (numeroMesaCtrl.text.isEmpty || capacidadCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Todos los campos son obligatorios')),
                          );
                          return;
                        }
                        try {
                          final mesa = Mesa(
                            id: mesaEdit?.id,
                            numeroMesa: int.tryParse(numeroMesaCtrl.text) ?? 1,
                            capacidad: int.tryParse(capacidadCtrl.text) ?? 1,
                            estado: estado,
                          );
                          if (mesaEdit == null) {
                            await _service.createMesa(mesa);
                          } else {
                            await _service.updateMesa(mesa);
                          }
                          Navigator.pop(ctx);
                          _refresh();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar mesa: $e')),
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
        title: const Text('Mesas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF5F8FA),
      body: FutureBuilder<List<Mesa>>(
        future: _futureMesas,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: \\${snap.error}', style: TextStyle(color: Colors.red)));
          }
          final mesas = snap.requireData;
          if (mesas.isEmpty) {
            return const Center(child: Text('No hay mesas.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: mesas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final mesa = mesas[i];
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
                        child: const Icon(Icons.table_bar, color: Color(0xFF2196F3), size: 30),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mesa #${mesa.numeroMesa}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.people, size: 18, color: Color(0xFF43A047)),
                                const SizedBox(width: 4),
                                Text('Capacidad: ${mesa.capacidad}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _estadoColor(mesa.estado).withOpacity(0.13),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                mesa.estado[0].toUpperCase() + mesa.estado.substring(1),
                                style: TextStyle(fontSize: 13, color: _estadoColor(mesa.estado), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
                            tooltip: 'Editar',
                            onPressed: () => _showAddDialog(mesaEdit: mesa),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFD32F2F)),
                            tooltip: 'Eliminar',
                            onPressed: () async {
                              if (mesa.id != null) {
                                await _service.deleteMesa(mesa.id!);
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
        tooltip: 'Agregar Mesa',
      ),
    );

  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'disponible':
        return const Color(0xFF43A047);
      case 'ocupada':
        return const Color(0xFF2196F3);
      case 'reservada':
        return const Color(0xFFFFA000);
      case 'mantenimiento':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }
  }

