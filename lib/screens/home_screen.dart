import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:umg_activo_colaborador/screens/screens.dart';
import 'package:umg_activo_colaborador/services/session_services.dart';
import 'package:umg_activo_colaborador/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = 'home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _userData = {};

  double _totalInvested = 0;
  bool _isLoadingInvestment = true;

  int _totalActivos = 0;
  int _asignados = 0;
  int _enAlmacen = 0;
  int _proximasBajas = 0;
  int _totalAsignaciones = 0;
  int _asignacionesActivas = 0;
  int _asignacionesVencidas = 0;
  int _totalColaboradores = 0;
  Map<String, double> _bienesPorEmpleado = {};
  bool _isLoadingStats = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _userData = args;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInvestmentSummary();
    _loadDashboardStats();
  }

  // ── Permisos por rol ──────────────────────────────────────────────
  String get _role => _userData['role'] ?? SessionService().role ?? '';

  bool get _canSeeColaboradores =>
      ['ADMINISTRADOR', 'INVENTARIO'].contains(_role);
  bool get _canSeeUsuarios => _role == 'ADMINISTRADOR';
  bool get _canSeeActivos =>
      ['ADMINISTRADOR', 'COMPRAS', 'INVENTARIO', 'FINANZAS'].contains(_role);
  bool get _canSeeAsignaciones =>
      ['ADMINISTRADOR', 'COMPRAS', 'INVENTARIO'].contains(_role);
  bool get _canSeeProveedores =>
      ['ADMINISTRADOR', 'COMPRAS', 'INVENTARIO'].contains(_role);
  bool get _canSeeDepartamentos => _role == 'ADMINISTRADOR';
  bool get _canSeePartidas => ['ADMINISTRADOR', 'FINANZAS'].contains(_role);
  bool get _canSeeProximasBajas =>
      ['ADMINISTRADOR', 'INVENTARIO', 'FINANZAS'].contains(_role);

  // ── Carga de datos ────────────────────────────────────────────────
  Future<void> _loadInvestmentSummary() async {
    try {
      final credentials = base64Encode(utf8.encode('admin:admin123'));
      final response = await http.get(
        Uri.parse(
            'https://datos-gh6q.onrender.com/api/reports/invested-assets/summary'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _totalInvested = (data['totalInvested'] as num).toDouble();
          _isLoadingInvestment = false;
        });
      } else {
        setState(() => _isLoadingInvestment = false);
      }
    } catch (e) {
      setState(() => _isLoadingInvestment = false);
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final credentials = base64Encode(utf8.encode('admin:admin123'));

      final responses = await Future.wait([
        http.get(
          Uri.parse('https://datos-gh6q.onrender.com/api/inventory/assets'),
          headers: {'Authorization': 'Basic $credentials'},
        ),
        http.get(
          Uri.parse(
              'https://datos-gh6q.onrender.com/api/reports/upcoming-disposals'),
          headers: {'Authorization': 'Basic $credentials'},
        ),
        http.get(
          Uri.parse('https://datos-gh6q.onrender.com/api/assignments'),
          headers: {'Authorization': 'Basic $credentials'},
        ),
        http.get(
          Uri.parse('https://datos-gh6q.onrender.com/api/data/employees'),
          headers: {'Authorization': 'Basic $credentials'},
        ),
      ]);

      // Activos
      if (responses[0].statusCode == 200) {
        final List<dynamic> activos = json.decode(responses[0].body);
        int asignados = 0, enAlmacen = 0;
        for (final a in activos) {
          final s = a['status'] ?? '';
          if (s == 'ASIGNADO') asignados++;
          if (s == 'EN_ALMACEN') enAlmacen++;
        }
        setState(() {
          _totalActivos = activos.length;
          _asignados = asignados;
          _enAlmacen = enAlmacen;
        });
      }

      // Próximas bajas
      if (responses[1].statusCode == 200) {
        final List<dynamic> bajas = json.decode(responses[1].body);
        setState(() => _proximasBajas = bajas.length);
      }

      // Asignaciones
      if (responses[2].statusCode == 200) {
        final List<dynamic> asig = json.decode(responses[2].body);
        int activas = 0, vencidas = 0;
        for (final a in asig) {
          final s = a['status'] ?? '';
          if (s == 'ACTIVA') activas++;
          if (s == 'VENCIDA') vencidas++;
        }
        setState(() {
          _totalAsignaciones = asig.length;
          _asignacionesActivas = activas;
          _asignacionesVencidas = vencidas;
        });
        _calcularBienesPorEmpleado(asig);
      }

      // Colaboradores
      if (responses[3].statusCode == 200) {
        final List<dynamic> colabs = json.decode(responses[3].body);
        setState(() => _totalColaboradores = colabs.length);
      }

      setState(() => _isLoadingStats = false);
    } catch (e) {
      setState(() => _isLoadingStats = false);
    }
  }

  void _calcularBienesPorEmpleado(List<dynamic> asignaciones) {
    final Map<String, double> mapa = {};
    for (final a in asignaciones) {
      final nombre = a['employee']?['fullName'] ?? 'Desconocido';
      final costo = (a['asset']?['acquisitionCost'] as num?)?.toDouble() ?? 0;
      mapa[nombre] = (mapa[nombre] ?? 0) + costo;
    }
    final sorted = Map.fromEntries(
      mapa.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    setState(() => _bienesPorEmpleado = sorted);
  }

  String get _username => _userData['username'] ?? 'Usuario';
  String? get _employeeId => _userData['employeeId']?.toString();

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

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: 'Menú Principal',
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_outlined),
            onPressed: () {
              SessionService().clearSession();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 16),
            _buildKpiRow(),
            const SizedBox(height: 16),
            if (_canSeeActivos) ...[
              _buildAssetStatusCard(),
              const SizedBox(height: 16),
            ],
            if (_canSeeAsignaciones) ...[
              _buildAssignmentsCard(),
              const SizedBox(height: 16),
            ],
            if (_canSeeAsignaciones && _bienesPorEmpleado.isNotEmpty) ...[
              _buildBienesEmpleadoCard(),
              const SizedBox(height: 16),
            ],
            if (_canSeeActivos) ...[
              _buildInvestmentCard(),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  // ── Drawer ────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF5C0F30)),
            child: Text(
              'Menú de Navegación',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          // ── Consulta ──────────────────────────────────────────
          if (_canSeeColaboradores)
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Colaboradores'),
              onTap: () =>
                  Navigator.pushNamed(context, ColaboradoresScreen.routeName),
            ),
          if (_canSeeUsuarios)
            ListTile(
              leading: const Icon(Icons.emoji_people_outlined),
              title: const Text('Usuarios'),
              onTap: () =>
                  Navigator.pushNamed(context, UsuariosScreen.routeName),
            ),
          if (_canSeeActivos)
            ListTile(
              leading: const Icon(Icons.computer_outlined),
              title: const Text('Activos'),
              onTap: () =>
                  Navigator.pushNamed(context, ActivosScreen.routeName),
            ),
          if (_canSeeAsignaciones)
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text('Asignaciones'),
              onTap: () =>
                  Navigator.pushNamed(context, AsignacionesScreen.routeName),
            ),
          if (_canSeeProveedores)
            ListTile(
              leading: const Icon(Icons.store_outlined),
              title: const Text('Proveedores'),
              onTap: () =>
                  Navigator.pushNamed(context, ProveedoresScreen.routeName),
            ),
          if (_canSeeDepartamentos)
            ListTile(
              leading: const Icon(Icons.business_outlined),
              title: const Text('Departamentos'),
              onTap: () =>
                  Navigator.pushNamed(context, DepartamentosScreen.routeName),
            ),
          if (_canSeePartidas)
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Partidas Presupuestarias'),
              onTap: () =>
                  Navigator.pushNamed(context, PartidasScreen.routeName),
            ),
          if (_canSeeProximasBajas)
            ListTile(
              leading: const Icon(Icons.outbox_outlined),
              title: const Text('Próximas Bajas'),
              onTap: () =>
                  Navigator.pushNamed(context, ProximasBajasScreen.routeName),
            ),

          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Mis asignaciones'),
            onTap: () =>
                Navigator.pushNamed(context, MisAsignacionesScreen.routeName),
          ),
        ],
      ),
    );
  }

  // ── Tarjeta de bienvenida ─────────────────────────────────────────
  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF5C0F30).withOpacity(0.3),
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
                  const Text('Bienvenido,',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  Text(
                    _username.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C0F30).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF8B1A4A).withOpacity(0.6)),
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
                    Text('ID Empleado: $_employeeId',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KPIs ──────────────────────────────────────────────────────────
  Widget _buildKpiRow() {
    final kpis = <_KpiData>[];

    if (_canSeeActivos) {
      kpis.add(_KpiData(
        icon: Icons.computer_outlined,
        label: 'Total Activos',
        value: _totalActivos.toString(),
        color: const Color(0xFF8B1A4A),
      ));
    }
    if (_canSeeColaboradores) {
      kpis.add(_KpiData(
        icon: Icons.people_outline,
        label: 'Colaboradores',
        value: _totalColaboradores.toString(),
        color: Colors.blue,
      ));
    }
    if (_canSeeAsignaciones) {
      kpis.add(_KpiData(
        icon: Icons.assignment_outlined,
        label: 'Asignaciones',
        value: _totalAsignaciones.toString(),
        color: Colors.teal,
      ));
    }
    if (_canSeeProximasBajas) {
      kpis.add(_KpiData(
        icon: Icons.outbox_outlined,
        label: 'Próx. Bajas',
        value: _proximasBajas.toString(),
        color: Colors.orange,
      ));
    }

    if (kpis.isEmpty) return const SizedBox.shrink();

    return _isLoadingStats
        ? const Center(child: CircularProgressIndicator())
        : GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.9,
            children: kpis.map((k) => _buildKpiCard(k)).toList(),
          );
  }

  Widget _buildKpiCard(_KpiData k) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: k.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(k.icon, color: k.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(k.value,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: k.color)),
                  Text(k.label,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Gráfica estado de activos ─────────────────────────────────────
  Widget _buildAssetStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoadingStats
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estado de Activos',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$_totalActivos activos en total',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (_totalActivos + 5).toDouble(),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              const labels = [
                                'Asignados',
                                'En Almacén',
                                'Próx. Bajas'
                              ];
                              return BarTooltipItem(
                                '${labels[groupIndex]}\n${rod.toY.toInt()}',
                                const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) {
                                const labels = [
                                  'Asignados',
                                  'En Almacén',
                                  'Próx. Bajas'
                                ];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(labels[value.toInt()],
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.center),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 11)),
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 5,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.15),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _bar(0, _asignados.toDouble(), Colors.green),
                          _bar(1, _enAlmacen.toDouble(),
                              const Color(0xFF8B1A4A)),
                          _bar(2, _proximasBajas.toDouble(), Colors.orange),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(
                          label: 'Asignados',
                          count: _asignados,
                          color: Colors.green),
                      _StatChip(
                          label: 'En Almacén',
                          count: _enAlmacen,
                          color: const Color(0xFF8B1A4A)),
                      _StatChip(
                          label: 'Próx. Bajas',
                          count: _proximasBajas,
                          color: Colors.orange),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 40,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  // ── Gráfica asignaciones ──────────────────────────────────────────
  Widget _buildAssignmentsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoadingStats
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estado de Asignaciones',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$_totalAsignaciones asignaciones en total',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: _asignacionesActivas.toDouble(),
                            title: 'Activas\n$_asignacionesActivas',
                            radius: 55,
                            color: Colors.green,
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11),
                          ),
                          PieChartSectionData(
                            value: _asignacionesVencidas.toDouble(),
                            title: 'Vencidas\n$_asignacionesVencidas',
                            radius: 55,
                            color: Colors.red,
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11),
                          ),
                          if (_totalAsignaciones -
                                  _asignacionesActivas -
                                  _asignacionesVencidas >
                              0)
                            PieChartSectionData(
                              value: (_totalAsignaciones -
                                      _asignacionesActivas -
                                      _asignacionesVencidas)
                                  .toDouble(),
                              title:
                                  'Otras\n${_totalAsignaciones - _asignacionesActivas - _asignacionesVencidas}',
                              radius: 55,
                              color: Colors.blue,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(
                          label: 'Activas',
                          count: _asignacionesActivas,
                          color: Colors.green),
                      _StatChip(
                          label: 'Vencidas',
                          count: _asignacionesVencidas,
                          color: Colors.red),
                      _StatChip(
                          label: 'Otras',
                          count: _totalAsignaciones -
                              _asignacionesActivas -
                              _asignacionesVencidas,
                          color: Colors.blue),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  // ── Gráfica bienes por empleado ───────────────────────────────────
  Widget _buildBienesEmpleadoCard() {
    final entries = _bienesPorEmpleado.entries.toList();
    final maxVal = entries.isEmpty
        ? 1.0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    final colors = [
      const Color(0xFF8B1A4A),
      const Color(0xFF9C27B0),
      Colors.teal,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.indigo,
      Colors.pink,
    ];

    final totalBienes = _bienesPorEmpleado.values.fold(0.0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoadingStats
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienes por Empleado',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Valor total de activos asignados por persona',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Barras horizontales por empleado
                  ...entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final nombre = entry.value.key;
                    final valor = entry.value.value;
                    final porcentaje = maxVal > 0 ? valor / maxVal : 0.0;
                    final color = colors[index % colors.length];

                    final partes = nombre.split(' ');
                    final nombreCorto = partes.length >= 2
                        ? '${partes[0]} ${partes[1]}'
                        : nombre;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Avatar inicial
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: color.withOpacity(0.4)),
                                ),
                                child: Center(
                                  child: Text(
                                    nombre[0].toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: color),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  nombreCorto,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Q ${valor.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: porcentaje,
                              minHeight: 10,
                              backgroundColor: color.withOpacity(0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Total general
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total en bienes asignados',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Q ${totalBienes.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCE93D8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  // ── Gráfica inversión ─────────────────────────────────────────────
  Widget _buildInvestmentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoadingInvestment
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resumen Financiero',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Total invertido en activos',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    'Q ${_totalInvested.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCE93D8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 45,
                        sections: [
                          PieChartSectionData(
                            value: _totalInvested,
                            title: 'Invertido',
                            radius: 50,
                            color: const Color(0xFF8B1A4A),
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────
class _KpiData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _KpiData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Center(
            child: Text(count.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14, color: color)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
