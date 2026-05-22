import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:umg_activo_colaborador/screens/screens.dart';
import 'package:umg_activo_colaborador/widgets/widgets.dart';

class CrearEmpleadoScreen extends StatefulWidget {
  const CrearEmpleadoScreen({super.key});
  static const String routeName = '/crear-empleado';

  @override
  State<CrearEmpleadoScreen> createState() => _CrearEmpleadoScreenState();
}

class _CrearEmpleadoScreenState extends State<CrearEmpleadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  List<Map<String, dynamic>> _departamentos = [];
  int? _selectedDeptId;
  bool _isLoadingDepts = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchDepartamentos();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchDepartamentos() async {
    try {
      final credentials = base64Encode(utf8.encode('admin:admin123'));
      final response = await http.get(
        Uri.parse('https://datos-gh6q.onrender.com/api/data/departments'),
        headers: {'Authorization': 'Basic $credentials'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _departamentos = data
              .map((e) => {'id': e['id'], 'name': e['name']})
              .toList();
          if (_departamentos.isNotEmpty) {
            _selectedDeptId = _departamentos[0]['id'];
          }
          _isLoadingDepts = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingDepts = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDeptId == null) return;

    setState(() => _isSubmitting = true);

    try {
      final credentials = base64Encode(utf8.encode('admin:admin123'));
      final response = await http.post(
        Uri.parse('https://datos-gh6q.onrender.com/api/data/employees'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'departmentId': _selectedDeptId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (mounted) {
          _showSuccess(
            '¡Empleado creado exitosamente!',
            'ID asignado: ${data['id']}\nGuárdalo para crear el usuario.',
            data['id'],
          );
        }
      } else {
        _showError('Error al crear empleado: ${response.statusCode}');
      }
    } catch (e) {
      _showError('No se pudo conectar al servidor');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSuccess(String title, String message, int employeeId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                CrearUsuarioScreen.routeName,
                arguments: {'employeeId': employeeId},
              );
            },
            child: const Text('Crear usuario'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(title: 'Crear Empleado'),
      body: _isLoadingDepts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C0F30).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF8B1A4A).withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.person_add_outlined,
                              color: Color(0xFFCE93D8)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Completa los datos del nuevo empleado',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nombre completo
                    TextFormField(
                      controller: _fullNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
                        hintText: 'Mario Rodriguez',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa el nombre completo'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'mario.rodriguez@empresa.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa el correo';
                        }
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(v.trim())) {
                          return 'Correo no válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Departamento
                    DropdownButtonFormField<int>(
                      value: _selectedDeptId,
                      decoration: InputDecoration(
                        labelText: 'Departamento',
                        prefixIcon: const Icon(Icons.business_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                      items: _departamentos
                          .map((d) => DropdownMenuItem<int>(
                                value: d['id'] as int,
                                child: Text(d['name'] as String),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDeptId = v),
                      validator: (v) =>
                          v == null ? 'Selecciona un departamento' : null,
                    ),
                    const SizedBox(height: 32),

                    // Botón
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
                            : const Icon(Icons.save_outlined),
                        label: Text(
                            _isSubmitting ? 'Guardando...' : 'Crear Empleado'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}