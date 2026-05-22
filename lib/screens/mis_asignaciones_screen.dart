import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/mis_asignaciones_model.dart';
import '../services/session_services.dart';
import '../widgets/widgets.dart';

class MisAsignacionesScreen extends StatefulWidget {
  const MisAsignacionesScreen({super.key});

  static const routeName = 'mis-asignaciones';

  @override
  State<MisAsignacionesScreen> createState() => _MisAsignacionesScreenState();
}

class _MisAsignacionesScreenState extends State<MisAsignacionesScreen> {
  List<MisAsignacionesModel> _misAsignaciones = [];
  List<MisAsignacionesModel> _pendientes = [];

  bool _isLoading = true;
  String? _error;

  String get _credentials {
    final session = SessionService();

    return base64Encode(
      utf8.encode(
        '${session.username}:${session.password}',
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final responses = await Future.wait([
        http.get(
          Uri.parse(
            'https://datos-gh6q.onrender.com/api/employee/me/assignments',
          ),
          headers: {
            'Authorization': 'Basic $_credentials',
          },
        ),
        http.get(
          Uri.parse(
            'https://datos-gh6q.onrender.com/api/employee/me/pending-assignments',
          ),
          headers: {
            'Authorization': 'Basic $_credentials',
          },
        ),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final activas = json.decode(responses[0].body);
        final pendientes = json.decode(responses[1].body);

        setState(() {
          _misAsignaciones = (activas as List)
              .map((e) => MisAsignacionesModel.fromMap(e))
              .toList();

          _pendientes = (pendientes as List)
              .map((e) => MisAsignacionesModel.fromMap(e))
              .toList();

          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error obteniendo datos';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'No se pudo conectar';
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmarAsignacion(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar asignación'),
        content: const Text(
          '¿Deseas confirmar esta asignación?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.post(
        Uri.parse(
          'https://datos-gh6q.onrender.com/api/employee/me/assignments/$id/confirm',
        ),
        headers: {
          'Authorization': SessionService().basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asignación confirmada'),
          ),
        );

        _fetchData();
      }
    } catch (_) {}
  }

  void _mostrarQr(int assetId) {
    final url =
        'https://datos-gh6q.onrender.com/api/employee/me/assets/$assetId/qr.png';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Código QR'),
        content: SizedBox(
          width: 250,
          height: 250,
          child: Image.network(
            url,
            headers: {
              'Authorization': 'Basic $_credentials',
            },
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);

      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
        title: 'Mis Asignaciones',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text(
            'Pendientes por confirmar',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._pendientes.map(
            (a) => _cardPendiente(a),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mis activos asignados',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._misAsignaciones.map(
            (a) => _cardActiva(a),
          ),
        ],
      ),
    );
  }

  Widget _cardPendiente(MisAsignacionesModel a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              a.asset.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Código: ${a.asset.assetCode}'),
            Text('Serie: ${a.asset.serialNumber}'),
            Text('Ubicación: ${a.asset.location}'),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _confirmarAsignacion(a.id);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Confirmar asignación',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardActiva(MisAsignacionesModel a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    a.asset.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _mostrarQr(a.asset.id);
                  },
                  icon: const Icon(
                    Icons.qr_code_2_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Código: ${a.asset.assetCode}'),
            Text('Serie: ${a.asset.serialNumber}'),
            Text('Ubicación: ${a.asset.location}'),
            const SizedBox(height: 8),
            Text(
              'Q ${a.asset.acquisitionCost.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Text(
              'Asignado: ${_formatDate(a.assignedAt)}',
            ),
            Text(
              'Retorno esperado: ${_formatDate(a.expectedReturnAt)}',
            ),
          ],
        ),
      ),
    );
  }
}
