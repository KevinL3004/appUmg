import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:umg_activo_colaborador/models/models.dart';
import 'package:umg_activo_colaborador/widgets/widgets.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});
  static const String routeName = '/usuarios';

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List<UsuariosModel> _usuarios = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();
  }

  Future<void> _fetchUsuarios() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final credentials = base64Encode(utf8.encode('admin:admin123'));

      final response = await http.get(
        Uri.parse('https://datos-gh6q.onrender.com/api/admin/users'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _usuarios = data.map((e) => UsuariosModel.fromMap(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error del servidor: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'No se pudo conectar al servidor';
        _isLoading = false;
      });
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'ADMINISTRADOR':
        return const Color(0xFF8B1A4A);
      case 'EMPLEADO':
        return Colors.blue;
      case 'COMPRAS':
        return Colors.teal;
      case 'INVENTARIO':
        return Colors.orange;
      case 'FINANZAS':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'ADMINISTRADOR':
        return 'Administrador';
      case 'EMPLEADO':
        return 'Empleado';
      case 'COMPRAS':
        return 'Compras';
      case 'INVENTARIO':
        return 'Inventario';
      case 'FINANZAS':
        return 'Finanzas';
      default:
        return role;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'ADMINISTRADOR':
        return Icons.admin_panel_settings_outlined;
      case 'EMPLEADO':
        return Icons.person_outline;
      case 'COMPRAS':
        return Icons.shopping_cart_outlined;
      case 'INVENTARIO':
        return Icons.inventory_2_outlined;
      case 'FINANZAS':
        return Icons.attach_money_outlined;
      default:
        return Icons.person_outline;
    }
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '-';
    try {
      final d = DateTime.parse(date);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(title: 'Usuarios'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchUsuarios,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_usuarios.isEmpty) {
      return const Center(child: Text('No hay usuarios registrados'));
    }

    return Column(
      children: [
        // Contador
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_usuarios.length} usuarios registrados',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchUsuarios,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: _usuarios.length,
              itemBuilder: (context, index) {
                final usuario = _usuarios[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Avatar con ícono de rol
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              _roleColor(usuario.role).withOpacity(0.15),
                          child: Icon(
                            _roleIcon(usuario.role),
                            color: _roleColor(usuario.role),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usuario.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Creado: ${_formatDate(usuario.createdAt)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              if (usuario.employeeId != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.badge_outlined, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ID Empleado: ${usuario.employeeId}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Badge de rol
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _roleColor(usuario.role).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _roleColor(usuario.role).withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            _roleLabel(usuario.role),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _roleColor(usuario.role),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}