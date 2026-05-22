import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:umg_activo_colaborador/widgets/widgets.dart';

class CrearAsignacionScreen extends StatefulWidget {
  const CrearAsignacionScreen({super.key});
  static const String routeName = '/crear-asignacion';

  @override
  State<CrearAsignacionScreen> createState() =>
      _CrearAsignacionScreenState();
}

class _CrearAsignacionScreenState extends State<CrearAsignacionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Catálogos
  List<Map<String, dynamic>> _empleados = [];
  List<Map<String, dynamic>> _activos = [];
  bool _isLoadingCatalogos = true;

  // Selecciones
  int? _selectedEmpleadoId;
  int? _selectedActivoId;

  // Fechas
  final _assignedAtCtrl = TextEditingController();
  final _expectedReturnCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCatalogos();
  }

  @override
  void dispose() {
    _assignedAtCtrl.dispose();
    _expectedReturnCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCatalogos() async {
    try {
      final credentials = base64Encode(utf8.encode('admin:admin123'));
      final responses = await Future.wait([
        http.get(
          Uri.parse('https://datos-gh6q.onrender.com/api/data/employees'),
          headers: {'Authorization': 'Basic $credentials'},
        ),
        http.get(
          Uri.parse('https://datos-gh6q.onrender.com/api/inventory/assets'),
          headers: {'Authorization': 'Basic $credentials'},
        ),
      ]);

      if (responses[0].statusCode == 200) {
        final List<dynamic> data = json.decode(responses[0].body);
        setState(() {
          _empleados = data
              .map((e) => {
                    'id': e['id'],
                    'fullName': e['fullName'],
                    'email': e['email'],
                    'department': e['department']?['name'] ?? '',
                  })
              .toList();
        });
      }

      if (responses[1].statusCode == 200) {
        final List<dynamic> data = json.decode(responses[1].body);
        // Solo activos disponibles (EN_ALMACEN)
        setState(() {
          _activos = data
              .where((a) => a['status'] == 'EN_ALMACEN')
              .map((a) => {
                    'id': a['id'],
                    'name': a['name'],
                    'assetCode': a['assetCode'],
                    'location': a['location'],
                  })
              .toList();
        });
      }
    } catch (e) {
      _showError('Error cargando catálogos');
    } finally {
      setState(() => _isLoadingCatalogos = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEmpleadoId == null) {
      _showError('Selecciona un empleado');
      return;
    }
    if (_selectedActivoId == null) {
      _showError('Selecciona un activo');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final credentials = base64Encode(utf8.encode('admin:admin123'));
      final response = await http.post(
        Uri.parse('https://datos-gh6q.onrender.com/api/assignments'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'assetId': _selectedActivoId,
          'employeeId': _selectedEmpleadoId,
          'assignedAt': _assignedAtCtrl.text.trim(),
          'expectedReturnAt': _expectedReturnCtrl.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) _showSuccess();
      } else {
        _showError('Error al crear asignación: ${response.statusCode}');
      }
    } catch (e) {
      _showError('No se pudo conectar al servidor');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('¡Asignación creada!', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Text(
            'El activo fue asignado exitosamente al empleado.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Listo'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(title: 'Crear Asignación'),
      body: _isLoadingCatalogos
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Selector de empleado ─────────────────────
                    const Text('Empleado',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF6D3B5A)),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF2A1020),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedEmpleadoId,
                          isExpanded: true,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Selecciona un empleado'),
                          ),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          items: _empleados.map((e) {
                            return DropdownMenuItem<int>(
                              value: e['id'] as int,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(e['fullName'] as String,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14)),
                                  Text(
                                    '${e['department']} · ${e['email']}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedEmpleadoId = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Selector de activo ───────────────────────
                    Row(
                      children: [
                        const Text('Activo disponible',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_activos.length} en almacén',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_activos.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.orange.withOpacity(0.4)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_outlined,
                                color: Colors.orange),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'No hay activos disponibles en almacén.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Lista de activos seleccionables
                      ...(_activos.map((a) {
                        final isSelected = _selectedActivoId == a['id'];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedActivoId = a['id']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF8B1A4A).withOpacity(0.2)
                                  : const Color(0xFF2A1020),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF8B1A4A)
                                    : const Color(0xFF6D3B5A),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.computer_outlined,
                                  color: isSelected
                                      ? const Color(0xFFCE93D8)
                                      : Colors.grey,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a['name'] as String,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: isSelected
                                              ? const Color(0xFFCE93D8)
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${a['assetCode']} · ${a['location']}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList()),

                    const SizedBox(height: 20),

                    // ── Fechas ───────────────────────────────────
                    TextFormField(
                      controller: _assignedAtCtrl,
                      readOnly: true,
                      onTap: () => _pickDate(_assignedAtCtrl),
                      decoration: InputDecoration(
                        labelText: 'Fecha de asignación',
                        prefixIcon:
                            const Icon(Icons.calendar_today_outlined),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Selecciona la fecha de asignación'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _expectedReturnCtrl,
                      readOnly: true,
                      onTap: () => _pickDate(_expectedReturnCtrl),
                      decoration: InputDecoration(
                        labelText: 'Fecha esperada de devolución',
                        prefixIcon: const Icon(Icons.event_outlined),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Selecciona la fecha de devolución'
                          : null,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.assignment_turned_in_outlined),
                        label: Text(_isSubmitting
                            ? 'Guardando...'
                            : 'Crear Asignación'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}