import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:umg_activo_colaborador/models/proximas_bajas_model.dart';
import 'package:umg_activo_colaborador/widgets/widgets.dart';

class ProximasBajasScreen extends StatefulWidget {
  const ProximasBajasScreen({super.key});
  static const String routeName = '/proximas-bajas';

  @override
  State<ProximasBajasScreen> createState() => _ProximasBajasScreenState();
}

class _ProximasBajasScreenState extends State<ProximasBajasScreen> {
  List<ProximasBajasModel> _bajas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBajas();
  }

  Future<void> _fetchBajas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final credentials = base64Encode(utf8.encode('admin:admin123'));
      final response = await http.get(
        Uri.parse(
          'https://datos-gh6q.onrender.com/api/reports/upcoming-disposals',
        ),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _bajas = data.map((e) => ProximasBajasModel.fromMap(e)).toList();
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
      case 'ASIGNADO':
        return Colors.green;
      case 'EN_ALMACEN':
        return Colors.orange;
      case 'BAJA':
        return Colors.red;
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
      case 'BAJA':
        return 'Baja';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(title: 'Próximas Bajas'),
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
              onPressed: _fetchBajas,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_bajas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 12),
            Text(
              'Sin próximas bajas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              'No hay activos próximos a darse de baja',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Banner informativo
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_outlined,
                  color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_bajas.length} activo${_bajas.length == 1 ? '' : 's'} próximo${_bajas.length == 1 ? '' : 's'} a darse de baja',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchBajas,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _bajas.length,
              itemBuilder: (context, index) {
                final baja = _bajas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado
                        Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                baja.name,
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
                                color:
                                    _statusColor(baja.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _statusColor(baja.status)
                                      .withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                _statusLabel(baja.status),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor(baja.status),
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
                              baja.assetCode,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.location_on_outlined, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              baja.location,
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
                              'S/N: ${baja.serialNumber}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const Spacer(),
                            Text(
                              'Q ${baja.acquisitionCost.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Custodio si tiene
                        if (baja.currentCustodian != null) ...[
                          const Divider(height: 14),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  baja.currentCustodian!.fullName,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                baja.currentCustodian!.departmentName,
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
          ),
        ),
      ],
    );
  }
}
