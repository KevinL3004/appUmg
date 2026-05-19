
import 'package:flutter/material.dart';
import 'package:umg_activo_colaborador/screens/screens.dart';
import 'package:umg_activo_colaborador/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = 'home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _userData = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _userData = args;
    }
  }

  String get _username => _userData['username'] ?? 'Usuario';
  String get _role => _userData['role'] ?? '-';
  String? get _employeeId => _userData['employeeId']?.toString();

  String _roleLabel(String role) {
    switch (role) {
      case 'ADMINISTRADOR':
        return 'Administrador';
      case 'EMPLEADO':
        return 'Empleado';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: 'Menú Principal',
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_outlined),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF5C0F30),
              ),
              child: Text(
                'Menú de Navegación',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Colaboradores'),
              onTap: () => Navigator.pushNamed(
                context,
                ColaboradoresScreen.routeName,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.computer_outlined),
              title: const Text('Activos'),
              onTap: () => Navigator.pushNamed(
                context,
                ActivosScreen.routeName,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text('Asignaciones'),
              onTap: () => Navigator.pushNamed(
                context,
                AsignacionesScreen.routeName,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.store_outlined),
              title: const Text('Proveedores'),
              onTap: () => Navigator.pushNamed(
                context,
                ProveedoresScreen.routeName,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.business_outlined),
              title: const Text('Departamentos'),
              onTap: () => Navigator.pushNamed(
                context,
                DepartamentosScreen.routeName,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de bienvenida
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          const Color(0xFF5C0F30).withOpacity(0.3),
                      child: Text(
                        _username[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCE93D8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bienvenido,',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          Text(
                            _username.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5C0F30).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF8B1A4A).withOpacity(0.6),
                              ),
                            ),
                            child: Text(
                              _roleLabel(_role),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFCE93D8),
                              ),
                            ),
                          ),
                          if (_employeeId != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'ID Empleado: $_employeeId',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Accesos rápidos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Fila 1
            Row(
              children: [
                _QuickAccessCard(
                  icon: Icons.people,
                  label: 'Colaboradores',
                  onTap: () => Navigator.pushNamed(
                    context,
                    ColaboradoresScreen.routeName,
                  ),
                ),
                const SizedBox(width: 12),
                _QuickAccessCard(
                  icon: Icons.computer_outlined,
                  label: 'Activos',
                  onTap: () => Navigator.pushNamed(
                    context,
                    ActivosScreen.routeName,
                  ),
                ),
                const SizedBox(width: 12),
                _QuickAccessCard(
                  icon: Icons.assignment_outlined,
                  label: 'Asignaciones',
                  onTap: () => Navigator.pushNamed(
                    context,
                    AsignacionesScreen.routeName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Fila 2
            Row(
              children: [
                _QuickAccessCard(
                  icon: Icons.store_outlined,
                  label: 'Proveedores',
                  onTap: () => Navigator.pushNamed(
                    context,
                    ProveedoresScreen.routeName,
                  ),
                ),
                const SizedBox(width: 12),
                _QuickAccessCard(
                  icon: Icons.business_outlined,
                  label: 'Departamentos',
                  onTap: () => Navigator.pushNamed(
                    context,
                    DepartamentosScreen.routeName,
                  ),
                ),
                const SizedBox(width: 12),
                // Espacio vacío para mantener el grid
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(icon, size: 28, color: const Color(0xFFCE93D8)),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}