import 'package:flutter/material.dart';
import 'reserva.dart';
import 'mesa.dart';
import 'mesa_service.dart';
import 'usuario.dart';
import 'usuario_service.dart';
import 'reserva_service.dart';

class ReservaScreen extends StatefulWidget {
  const ReservaScreen({super.key});

  @override
  State<ReservaScreen> createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  final _service = ReservaService();
  late Future<List<Reserva>> _futureReservas = Future.value([]);
  // Eliminado campo usuarios

  @override
  void initState() {
    super.initState();
    _futureReservas = _service.fetchReservas();
    // Ya no se cargan usuarios
  }

  void _refresh() {
    setState(() {
      _futureReservas = _service.fetchReservas();
    });
  }

  void _showAddDialog({Reserva? reservaEdit}) {
    int? selectedMesaId = (reservaEdit?.mesaId != null && reservaEdit?.mesaId != 0) ? reservaEdit!.mesaId : null;
    final nombreClienteCtrl = TextEditingController(text: reservaEdit?.nombreCliente ?? '');
    final cantidadPersonasCtrl = TextEditingController(text: reservaEdit?.cantidadPersonas != null ? reservaEdit!.cantidadPersonas.toString() : '');
    DateTime? fechaSeleccionada = reservaEdit?.fecha;
    final fechaCtrl = TextEditingController(text: reservaEdit?.fecha != null ? reservaEdit!.fecha.toIso8601String().split('T').first : '');
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return FutureBuilder(
          future: MesaService().fetchMesas(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
            }
            final mesas = snapshot.data! as List<Mesa>;
            if (selectedMesaId != null && !mesas.any((m) => m.id == selectedMesaId)) {
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
                        reservaEdit == null ? 'Nueva Reserva' : 'Editar Reserva',
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
                      TextField(
                        controller: nombreClienteCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nombre Cliente',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: const Color(0xFFF5F8FA),
                        ),
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
                        controller: cantidadPersonasCtrl,
                        decoration: InputDecoration(
                          labelText: 'Cantidad de Personas',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: const Color(0xFFF5F8FA),
                        ),
                        keyboardType: TextInputType.number,
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
                              if (selectedMesaId == null || nombreClienteCtrl.text.isEmpty || fechaCtrl.text.isEmpty || cantidadPersonasCtrl.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Todos los campos son obligatorios')),
                                );
                                return;
                              }
                              try {
                                final reserva = Reserva(
                                  id: reservaEdit?.id,
                                  mesaId: selectedMesaId!,
                                  usuarioId: 0, // Ya no se usa usuarioId real
                                  nombreCliente: nombreClienteCtrl.text,
                                  fecha: fechaSeleccionada ?? DateTime.now(),
                                  cantidadPersonas: int.tryParse(cantidadPersonasCtrl.text) ?? 1,
                                );
                                if (reservaEdit == null) {
                                  await _service.createReserva(reserva);
                                } else {
                                  // Aquí podrías implementar updateReserva si lo tienes
                                }
                                Navigator.pop(ctx);
                                _refresh();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al guardar reserva: $e')),
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
        title: const Text('Reservas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF5F8FA),
      body: FutureBuilder<List<Reserva>>(
        future: _futureReservas,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: \\${snap.error}', style: TextStyle(color: Colors.red)));
          }
          final reservas = snap.data ?? [];
          if (reservas.isEmpty) {
            return const Center(child: Text('No hay reservas.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reservas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final reserva = reservas[i];
              String fechaSimple = '${reserva.fecha.day.toString().padLeft(2, '0')}/${reserva.fecha.month.toString().padLeft(2, '0')}/${reserva.fecha.year}';
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
                        child: const Icon(Icons.event_seat, color: Color(0xFF2196F3), size: 30),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reserva #${reserva.id ?? ''}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.table_bar, size: 18, color: Color(0xFF43A047)),
                                const SizedBox(width: 4),
                                Text('Mesa: ${reserva.mesaId}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.person, size: 18, color: Color(0xFF2196F3)),
                                const SizedBox(width: 4),
                                Text('Cliente: ${reserva.nombreCliente}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Color(0xFF2196F3)),
                                const SizedBox(width: 4),
                                Text('Fecha: $fechaSimple', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.people, size: 16, color: Color(0xFF43A047)),
                                const SizedBox(width: 4),
                                Text('Personas: ${reserva.cantidadPersonas}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
                            tooltip: 'Editar',
                            onPressed: () => _showAddDialog(reservaEdit: reserva),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFD32F2F)),
                            tooltip: 'Eliminar',
                            onPressed: () async {
                              if (reserva.id != null) {
                                await _service.deleteReserva(reserva.id!);
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
        tooltip: 'Agregar Reserva',
      ),
    );
  }
}
