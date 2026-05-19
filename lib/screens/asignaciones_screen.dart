import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:umg_activo_colaborador/models/models.dart';
import 'package:umg_activo_colaborador/widgets/widgets.dart';

class AsignacionesScreen extends StatefulWidget {
  const AsignacionesScreen({super.key});
  static String routeName = 'asignaciones';

  @override
  State<AsignacionesScreen> createState() => _AsignacionesScreenState();
}

class _AsignacionesScreenState extends State<AsignacionesScreen> {
  List<AsignacionesModel> _asignaciones = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAsignaciones();
  }

  Future<void> _fetchAsignaciones() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final credentials = base64Encode(utf8.encode('admin:admin123'));

      final response = await http.get(
        Uri.parse('https://datos-gh6q.onrender.com/api/assignments'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _asignaciones =
              data.map((e) => AsignacionesModel.fromMap(e)).toList();
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

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVA':
        return Colors.green;
      case 'FINALIZADA':
        return Colors.blue;
      case 'VENCIDA':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'ACTIVA':
        return 'Activa';
      case 'FINALIZADA':
        return 'Finalizada';
      case 'VENCIDA':
        return 'Vencida';
      default:
        return status;
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
      appBar: const AppBarCustom(title: 'Asignaciones'),
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
            Text(_error!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchAsignaciones,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_asignaciones.isEmpty) {
      return const Center(child: Text('No hay asignaciones registradas'));
    }

    return RefreshIndicator(
      onRefresh: _fetchAsignaciones,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: _asignaciones.length,
        itemBuilder: (context, index) {
          final asignacion = _asignaciones[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado: activo + badge status
                  Row(
                    children: [
                      const Icon(Icons.assignment_outlined, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          asignacion.asset.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            asignacion.status,
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _statusColor(
                              asignacion.status,
                            ).withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          _statusLabel(asignacion.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(asignacion.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Código del activo
                  Row(
                    children: [
                      const Icon(Icons.qr_code, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        asignacion.asset.assetCode,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on_outlined, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        asignacion.asset.location,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(height: 14),

                  // Empleado
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          asignacion.employee.fullName,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.business_outlined, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        asignacion.employee.department.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(height: 14),

                  // Fechas
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'Asignado: ${_formatDate(asignacion.assignedAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      const Icon(Icons.event_outlined, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'Vence: ${_formatDate(asignacion.expectedReturnAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),

                  // Devuelto (solo si aplica)
                  if (asignacion.returnedAt != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 13,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Devuelto: ${_formatDate(asignacion.returnedAt!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}