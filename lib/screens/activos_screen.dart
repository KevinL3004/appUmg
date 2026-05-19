import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:umg_activo_colaborador/models/models.dart';
import 'package:umg_activo_colaborador/widgets/widgets.dart';

class ActivosScreen extends StatefulWidget {
  const ActivosScreen({super.key});
  static String routeName = 'activos';

  @override
  State<ActivosScreen> createState() => _ActivosScreenState();
}

class _ActivosScreenState extends State<ActivosScreen> {
  List<ActivosModel> _activos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchActivos();
  }

  Future<void> _fetchActivos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final credentials = base64Encode(utf8.encode('admin:admin123'));

      final response = await http.get(
        Uri.parse('https://datos-gh6q.onrender.com/api/inventory/assets'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _activos = data.map((e) => ActivosModel.fromMap(e)).toList();
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

  // Color e ícono según el status del activo
  Color _statusColor(String status) {
    switch (status) {
      case 'ASIGNADO':
        return Colors.green;
      case 'EN_ALMACEN':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'ASIGNADO':
        return 'Asignado';
      case 'EN_ALMACEN':
        return 'En almacén';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(title: 'Activos'),
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
              onPressed: _fetchActivos,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_activos.isEmpty) {
      return const Center(child: Text('No hay activos registrados'));
    }

    return RefreshIndicator(
      onRefresh: _fetchActivos,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: _activos.length,
        itemBuilder: (context, index) {
          final activo = _activos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado: nombre + badge de status
                  Row(
                    children: [
                      const Icon(Icons.computer_outlined, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activo.name,
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
                          color: _statusColor(activo.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _statusColor(activo.status).withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          _statusLabel(activo.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(activo.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Código y ubicación
                  Row(
                    children: [
                      const Icon(Icons.qr_code, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        activo.assetCode,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on_outlined, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        activo.location,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Serie y costo
                  Row(
                    children: [
                      const Icon(Icons.tag, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'S/N: ${activo.serialNumber}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        'Q ${activo.acquisitionCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Custodio (solo si tiene)
                  if (activo.currentCustodian != null) ...[
                    const Divider(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            activo.currentCustodian!.fullName,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          activo.currentCustodian!.departmentName,
                          style: const TextStyle(fontSize: 11),
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