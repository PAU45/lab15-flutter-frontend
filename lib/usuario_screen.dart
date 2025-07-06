import 'package:flutter/material.dart';
import 'usuario.dart';
import 'usuario_service.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  final _service = UsuarioService();
  late Future<List<Usuario>> _futureUsuarios;

  @override
  void initState() {
    super.initState();
    _futureUsuarios = _service.fetchUsuarios();
  }

  void _refresh() {
    setState(() {
      _futureUsuarios = _service.fetchUsuarios();
    });
  }

  void _showAddDialog({Usuario? usuarioEdit}) {
    final nombreCtrl = TextEditingController(text: usuarioEdit?.nombre ?? '');
    final emailCtrl = TextEditingController(text: usuarioEdit?.email ?? '');
    final passwordCtrl = TextEditingController();
    String rol = usuarioEdit?.rol ?? 'mesero';
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
                  usuarioEdit == null ? 'Nuevo Usuario' : 'Editar Usuario',
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
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordCtrl,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                    hintText: usuarioEdit != null ? '••••••' : null,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: rol,
                  decoration: InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: const Color(0xFFF5F8FA),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'mesero', child: Text('Mesero')),
                    DropdownMenuItem(value: 'cocina', child: Text('Cocina')),
                  ],
                  onChanged: (val) {
                    if (val != null) rol = val;
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
                        if (nombreCtrl.text.isEmpty || emailCtrl.text.isEmpty || (usuarioEdit == null && passwordCtrl.text.isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Todos los campos son obligatorios')),
                          );
                          return;
                        }
                        try {
                          final usuario = Usuario(
                            id: usuarioEdit?.id,
                            nombre: nombreCtrl.text,
                            email: emailCtrl.text,
                            password: passwordCtrl.text.isNotEmpty ? passwordCtrl.text : (usuarioEdit?.password ?? ''),
                            rol: rol,
                          );
                          if (usuarioEdit == null) {
                            await _service.createUsuario(usuario);
                          } else {
                            await _service.updateUsuario(usuario);
                          }
                          Navigator.pop(ctx);
                          _refresh();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar usuario: $e')),
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
        title: const Text('Usuarios', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF5F8FA),
      body: FutureBuilder<List<Usuario>>(
        future: _futureUsuarios,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: \\${snap.error}', style: TextStyle(color: Colors.red)));
          }
          final usuarios = snap.data ?? [];
          if (usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: usuarios.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final usuario = usuarios[i];
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
                        child: const Icon(Icons.person, color: Color(0xFF2196F3), size: 30),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usuario.nombre,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              usuario.email,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _rolColor(usuario.rol).withOpacity(0.13),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                usuario.rol[0].toUpperCase() + usuario.rol.substring(1),
                                style: TextStyle(fontSize: 13, color: _rolColor(usuario.rol), fontWeight: FontWeight.w600),
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
                            onPressed: () => _showAddDialog(usuarioEdit: usuario),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFD32F2F)),
                            tooltip: 'Eliminar',
                            onPressed: () async {
                              if (usuario.id != null) {
                                await _service.deleteUsuario(usuario.id!);
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
        tooltip: 'Agregar Usuario',
      ),
    );

  }

  Color _rolColor(String rol) {
    switch (rol) {
      case 'admin':
        return const Color(0xFF2196F3);
      case 'mesero':
        return const Color(0xFF43A047);
      case 'cocina':
        return const Color(0xFFFFA000);
      default:
        return Colors.grey;
    }
  }
  }
