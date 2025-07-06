


import 'package:flutter/material.dart';
import 'platos_screen.dart';
import 'mesas_screen.dart';
import 'usuario_screen.dart';
import 'pedidos_screen.dart';
import 'reserva_screen.dart';
import 'factura_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Restaurante',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF2196F3), // Azul principal
          primary: Color(0xFF2196F3), // Azul
          secondary: Color(0xFF43A047), // Verde
          background: Color(0xFFF5F9FF), // Fondo blanco-azulado
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF43A047), // Verde
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(vertical: 18),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF2196F3), width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF2196F3), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF43A047), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF2196F3)),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF2196F3),
          contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        fontFamily: 'Segoe UI',
      ),
      home: const MainMenu(),
    );
  }
}


class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema Restaurante'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _MenuButton(
                icon: Icons.fastfood,
                label: 'Platos',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlatosScreen())),
              ),
              _MenuButton(
                icon: Icons.table_bar,
                label: 'Mesas',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MesasScreen())),
              ),
              _MenuButton(
                icon: Icons.person,
                label: 'Usuarios',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsuarioScreen())),
              ),
              _MenuButton(
                icon: Icons.event_seat,
                label: 'Reservas',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReservaScreen())),
              ),
              _MenuButton(
                icon: Icons.receipt_long,
                label: 'Pedidos',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PedidosScreen())),
              ),
              _MenuButton(
                icon: Icons.request_quote,
                label: 'Facturas',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FacturaScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 22, color: Color(0xFF7B5EA7)),
            ],
          ),
        ),
      ),
    );
  }
}
