import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:umg_activo_colaborador/widgets/widgets.dart';

class CrearActivoScreen extends StatefulWidget {
  const CrearActivoScreen({super.key});
  static const String routeName = '/crear-activo';

  @override
  State<CrearActivoScreen> createState() => _CrearActivoScreenState();
}

class _CrearActivoScreenState extends State<CrearActivoScreen> {
  // ── Estado general ─────────────────────────────────────────────
  bool _isLoadingCatalogos = true;
  bool _facturaCreada = false;
  int? _purchaseInvoiceId;

  // ── Catálogos ──────────────────────────────────────────────────
  List<Map<String, dynamic>> _proveedores = [];
  List<Map<String, dynamic>> _partidas = [];
  int? _selectedSupplierId;
  int? _selectedBudgetLineId;

  // ── Form factura ───────────────────────────────────────────────
  final _facturaFormKey = GlobalKey<FormState>();
  final _invoiceNumberCtrl = TextEditingController();
  final _invoiceDateCtrl = TextEditingController();
  final _totalAmountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isCreatingFactura = false;

  // ── Form activo ────────────────────────────────────────────────
  final _activoFormKey = GlobalKey<FormState>();
  final _assetCodeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _serialNumberCtrl = TextEditingController();
  final _acquisitionDateCtrl = TextEditingController();
  final _acquisitionCostCtrl = TextEditingController();
  final _tagValueCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _selectedTagType = 'QR';
  bool _isCreatingActivo = false;

  @override
  void initState() {
    super.initState();
    _fetchCatalogos();
  }

  @override
  void dispose() {
    _invoiceNumberCtrl.dispose();
    _invoiceDateCtrl.dispose();
    _totalAmountCtrl.dispose();
    _notesCtrl.dispose();
    _assetCodeCtrl.dispose();
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _serialNumberCtrl.dispose();
    _acquisitionDateCtrl.dispose();
    _acquisitionCostCtrl.dispose();
    _tagValueCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCatalogos() async {
    try {
      final credentials = base64Encode(utf8.encode('admin:admin123'));
      final responses = await Future.wait([
        http.get(
          Uri.parse('https://datos-gh6q.onrender.com/api/data/suppliers'),
          headers: {'Authorization': 'Basic $credentials'},
        ),
        http.get(
          Uri.parse('https://datos-gh6q.onrender.com/api/data/budget-lines'),
          headers: {'Authorization': 'Basic $credentials'},
        ),
      ]);

      if (responses[0].statusCode == 200) {
        final List<dynamic> data = json.decode(responses[0].body);
        setState(() {
          _proveedores = data
              .map((e) => {'id': e['id'], 'name': e['name']})
              .toList();
          if (_proveedores.isNotEmpty) {
            _selectedSupplierId = _proveedores[0]['id'];
          }
        });
      }

      if (responses[1].statusCode == 200) {
        final List<dynamic> data = json.decode(responses[1].body);
        setState(() {
          _partidas = data
              .map((e) => {'id': e['id'], 'code': e['code']})
              .toList();
          if (_partidas.isNotEmpty) {
            _selectedBudgetLineId = _partidas[0]['id'];
          }
        });
      }
    } catch (e) {
      _showError('Error cargando catálogos');
    } finally {
      setState(() => _isLoadingCatalogos = false);
    }
  }

  Future<void> _crearFactura() async {
    if (!_facturaFormKey.currentState!.validate()) return;
    if (_selectedSupplierId == null || _selectedBudgetLineId == null) {
      _showError('Selecciona proveedor y partida');
      return;
    }

    setState(() => _isCreatingFactura = true);

    try {
      final credentials = base64Encode(utf8.encode('admin:admin123'));
      final response = await http.post(
        Uri.parse(
            'https://datos-gh6q.onrender.com/api/acquisitions/invoices'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'invoiceNumber': _invoiceNumberCtrl.text.trim(),
          'invoiceDate': _invoiceDateCtrl.text.trim(),
          'totalAmount': double.parse(_totalAmountCtrl.text.trim()),
          'supplierId': _selectedSupplierId,
          'budgetLineId': _selectedBudgetLineId,
          'notes': _notesCtrl.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          _purchaseInvoiceId = data['id'];
          _facturaCreada = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('✅ Factura creada — ID: $_purchaseInvoiceId'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError('Error al crear factura: ${response.statusCode}');
      }
    } catch (e) {
      _showError('No se pudo conectar al servidor');
    } finally {
      setState(() => _isCreatingFactura = false);
    }
  }

  Future<void> _crearActivo() async {
    if (!_activoFormKey.currentState!.validate()) return;

    setState(() => _isCreatingActivo = true);

    try {
      final credentials = base64Encode(utf8.encode('admin:admin123'));
      final response = await http.post(
        Uri.parse('https://datos-gh6q.onrender.com/api/inventory/assets'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'assetCode': _assetCodeCtrl.text.trim(),
          'name': _nameCtrl.text.trim(),
          'description': _descriptionCtrl.text.trim(),
          'serialNumber': _serialNumberCtrl.text.trim(),
          'acquisitionDate': _acquisitionDateCtrl.text.trim(),
          'acquisitionCost':
              double.parse(_acquisitionCostCtrl.text.trim()),
          'tagType': _selectedTagType,
          'tagValue': _tagValueCtrl.text.trim(),
          'location': _locationCtrl.text.trim(),
          'purchaseInvoiceId': _purchaseInvoiceId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('¡Activo creado!',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
              content: Text(
                  'ID del activo: ${data['id']}\n\n¿Deseas crear otro activo con la misma factura?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('No, terminar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _limpiarFormActivo();
                  },
                  child: const Text('Crear otro'),
                ),
              ],
            ),
          );
        }
      } else {
        _showError('Error al crear activo: ${response.statusCode}');
      }
    } catch (e) {
      _showError('No se pudo conectar al servidor');
    } finally {
      setState(() => _isCreatingActivo = false);
    }
  }

  void _limpiarFormActivo() {
    _assetCodeCtrl.clear();
    _nameCtrl.clear();
    _descriptionCtrl.clear();
    _serialNumberCtrl.clear();
    _acquisitionDateCtrl.clear();
    _acquisitionCostCtrl.clear();
    _tagValueCtrl.clear();
    _locationCtrl.clear();
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
      appBar: const AppBarCustom(title: 'Crear Activo'),
      body: _isLoadingCatalogos
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── SECCIÓN FACTURA ──────────────────────────
                  _sectionHeader(
                    icon: Icons.receipt_long_outlined,
                    title: 'Paso 1 — Factura de compra',
                    subtitle: _facturaCreada
                        ? '✅ Factura #$_purchaseInvoiceId creada'
                        : 'Crea la factura antes de registrar el activo',
                    done: _facturaCreada,
                  ),
                  const SizedBox(height: 16),

                  if (!_facturaCreada) ...[
                    Form(
                      key: _facturaFormKey,
                      child: Column(
                        children: [
                          _field(
                            ctrl: _invoiceNumberCtrl,
                            label: 'Número de factura',
                            hint: 'FAC-001',
                            icon: Icons.numbers_outlined,
                          ),
                          const SizedBox(height: 12),
                          _dateField(
                            ctrl: _invoiceDateCtrl,
                            label: 'Fecha de factura',
                          ),
                          const SizedBox(height: 12),
                          _field(
                            ctrl: _totalAmountCtrl,
                            label: 'Monto total',
                            hint: '30000',
                            icon: Icons.attach_money_outlined,
                            isNumber: true,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            value: _selectedSupplierId,
                            decoration: InputDecoration(
                              labelText: 'Proveedor',
                              prefixIcon:
                                  const Icon(Icons.store_outlined),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                              filled: true,
                            ),
                            items: _proveedores
                                .map((p) => DropdownMenuItem<int>(
                                      value: p['id'] as int,
                                      child: Text(p['name'] as String,
                                          overflow:
                                              TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedSupplierId = v),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            value: _selectedBudgetLineId,
                            decoration: InputDecoration(
                              labelText: 'Partida presupuestaria',
                              prefixIcon:
                                  const Icon(Icons.folder_outlined),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                              filled: true,
                            ),
                            items: _partidas
                                .map((p) => DropdownMenuItem<int>(
                                      value: p['id'] as int,
                                      child: Text(p['code'] as String),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedBudgetLineId = v),
                          ),
                          const SizedBox(height: 12),
                          _field(
                            ctrl: _notesCtrl,
                            label: 'Notas (opcional)',
                            hint: 'Descripción de la compra',
                            icon: Icons.notes_outlined,
                            required: false,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isCreatingFactura
                                  ? null
                                  : _crearFactura,
                              icon: _isCreatingFactura
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2),
                                    )
                                  : const Icon(
                                      Icons.receipt_outlined),
                              label: Text(_isCreatingFactura
                                  ? 'Creando factura...'
                                  : 'Crear Factura'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Factura ya creada
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.green.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Factura ID $_purchaseInvoiceId lista. Ahora registra el activo.',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _facturaCreada = false),
                            child: const Text('Editar'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ── SECCIÓN ACTIVO ───────────────────────────
                  _sectionHeader(
                    icon: Icons.computer_outlined,
                    title: 'Paso 2 — Datos del activo',
                    subtitle: _facturaCreada
                        ? 'Completa los datos del activo'
                        : 'Primero crea la factura',
                    done: false,
                  ),
                  const SizedBox(height: 16),

                  // Formulario activo (deshabilitado hasta que haya factura)
                  AnimatedOpacity(
                    opacity: _facturaCreada ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 300),
                    child: AbsorbPointer(
                      absorbing: !_facturaCreada,
                      child: Form(
                        key: _activoFormKey,
                        child: Column(
                          children: [
                            _field(
                              ctrl: _assetCodeCtrl,
                              label: 'Código de activo',
                              hint: 'ACT-001',
                              icon: Icons.qr_code_outlined,
                            ),
                            const SizedBox(height: 12),
                            _field(
                              ctrl: _nameCtrl,
                              label: 'Nombre del activo',
                              hint: 'Laptop Dell Latitude',
                              icon: Icons.label_outline,
                            ),
                            const SizedBox(height: 12),
                            _field(
                              ctrl: _descriptionCtrl,
                              label: 'Descripción',
                              hint: 'Equipo de trabajo',
                              icon: Icons.description_outlined,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 12),
                            _field(
                              ctrl: _serialNumberCtrl,
                              label: 'Número de serie',
                              hint: 'SN-001',
                              icon: Icons.numbers_outlined,
                            ),
                            const SizedBox(height: 12),
                            _dateField(
                              ctrl: _acquisitionDateCtrl,
                              label: 'Fecha de adquisición',
                            ),
                            const SizedBox(height: 12),
                            _field(
                              ctrl: _acquisitionCostCtrl,
                              label: 'Costo de adquisición',
                              hint: '14500',
                              icon: Icons.attach_money_outlined,
                              isNumber: true,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedTagType,
                              decoration: InputDecoration(
                                labelText: 'Tipo de etiqueta',
                                prefixIcon:
                                    const Icon(Icons.qr_code_2_outlined),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                filled: true,
                              ),
                              items: ['QR', 'BARCODE', 'NFC']
                                  .map((t) => DropdownMenuItem(
                                      value: t, child: Text(t)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedTagType = v!),
                            ),
                            const SizedBox(height: 12),
                            _field(
                              ctrl: _tagValueCtrl,
                              label: 'Valor de etiqueta',
                              hint: 'TAG-001',
                              icon: Icons.tag_outlined,
                            ),
                            const SizedBox(height: 12),
                            _field(
                              ctrl: _locationCtrl,
                              label: 'Ubicación',
                              hint: 'Oficina Central',
                              icon: Icons.location_on_outlined,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _isCreatingActivo
                                    ? null
                                    : _crearActivo,
                                icon: _isCreatingActivo
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.save_outlined),
                                label: Text(_isCreatingActivo
                                    ? 'Guardando...'
                                    : 'Crear Activo'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool done,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: done
                ? Colors.green.withOpacity(0.15)
                : const Color(0xFF5C0F30).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            done ? Icons.check_circle_outline : icon,
            color: done ? Colors.green : const Color(0xFFCE93D8),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    bool required = true,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
          : null,
    );
  }

  Widget _dateField({
    required TextEditingController ctrl,
    required String label,
  }) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      onTap: () => _pickDate(ctrl),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Seleccionar fecha',
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Selecciona una fecha' : null,
    );
  }
}