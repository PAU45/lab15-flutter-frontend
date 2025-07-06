import 'package:flutter/material.dart';
import 'plato_service.dart';
import 'plato.dart';

class PlatosScreen extends StatefulWidget {
  const PlatosScreen({super.key});

  @override
  State<PlatosScreen> createState() => _PlatosScreenState();
}

class _PlatosScreenState extends State<PlatosScreen> {
  final _service = PlatoService();
  late Future<List<Plato>> _futurePlatos;

  @override
  void initState() {
    super.initState();
    _futurePlatos = _service.fetchPlatos();
  }

  void _refresh() {
    setState(() {
      _futurePlatos = _service.fetchPlatos();
    });
  }

  void _showAddDialog({Plato? platoEdit}) {
    final nombreCtrl = TextEditingController(text: platoEdit?.nombre ?? '');
    final descCtrl = TextEditingController(text: platoEdit?.descripcion ?? '');
    final precioCtrl = TextEditingController(text: platoEdit?.precio != null ? platoEdit!.precio.toStringAsFixed(2) : '');
    final catCtrl = TextEditingController(text: platoEdit?.categoria ?? '');
    final urlCtrl = TextEditingController(text: platoEdit?.urlImagen ?? '');
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
                  platoEdit == null ? 'Nuevo Plato' : 'Editar Plato',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: nombreCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: precioCtrl,
                  decoration: InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: catCtrl,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: urlCtrl,
                  decoration: InputDecoration(
                    labelText: 'URL Imagen',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
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
                        if (nombreCtrl.text.isEmpty || descCtrl.text.isEmpty || precioCtrl.text.isEmpty || catCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Todos los campos son obligatorios')),
                          );
                          return;
                        }
                        try {
                          final plato = Plato(
                            id: platoEdit?.id,
                            nombre: nombreCtrl.text,
                            descripcion: descCtrl.text,
                            precio: double.tryParse(precioCtrl.text) ?? 0,
                            categoria: catCtrl.text,
                            urlImagen: urlCtrl.text.isEmpty ? null : urlCtrl.text,
                          );
                          if (platoEdit == null) {
                            await _service.createPlato(plato);
                          } else {
                            await _service.updatePlato(plato);
                          }
                          Navigator.pop(ctx);
                          _refresh();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar plato: $e')),
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
        title: const Text('Platos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF5F8FA),
      body: FutureBuilder<List<Plato>>(
        future: _futurePlatos,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: \\${snap.error}', style: TextStyle(color: Colors.red)));
          }
          final platos = snap.requireData;
          if (platos.isEmpty) {
            return const Center(child: Text('No hay platos.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: platos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final plato = platos[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 3,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: plato.urlImagen != null && plato.urlImagen!.isNotEmpty
                            ? Image.network(
                                plato.urlImagen!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                              )
                            : Container(
                                width: 56,
                                height: 56,
                                color: const Color(0xFFE3F2FD),
                                child: const Icon(Icons.fastfood, color: Color(0xFF2196F3), size: 32),
                              ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plato.nombre,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plato.descripcion,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF43A047).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    plato.categoria,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF43A047), fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'S/ ${plato.precio.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 15, color: Color(0xFF2196F3), fontWeight: FontWeight.bold),
                                ),
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
                            onPressed: () => _showAddDialog(platoEdit: plato),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFD32F2F)),
                            tooltip: 'Eliminar',
                            onPressed: () async {
                              if (plato.id != null) {
                                await _service.deletePlato(plato.id!);
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
        tooltip: 'Agregar Plato',
      ),
    );
  }
}
