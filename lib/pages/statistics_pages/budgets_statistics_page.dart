import 'package:flutter/material.dart';
import '../../Services/budget_service.dart';
import '../creation_pages/create_budget_page.dart';
import '../details_pages/budget_details_page.dart';

class BudgetsStatisticsPage extends StatefulWidget {
  const BudgetsStatisticsPage({super.key});

  @override
  State<BudgetsStatisticsPage> createState() => _BudgetsStatisticsPageState();
}

class _BudgetsStatisticsPageState extends State<BudgetsStatisticsPage> {
  final _budgetService = BudgetService();
  List<Map<String, dynamic>> _budgets = [];
  Map<String, dynamic> _summary = {
    'total_budgets': 0,
    'monthly': {'count': 0, 'total_amount': 0},
    'weekly': {'count': 0, 'total_amount': 0},
    'by_category': {},
  };
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all'; // all, monthly, weekly

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _budgetService.getBudgets(),
        _budgetService.getBudgetSummary(),
      ]);

      final budgetsResult = results[0];
      final summaryResult = results[1];

      if (!mounted) return;

      List<Map<String, dynamic>> budgets = [];

      if (budgetsResult['success']) {
        final data = budgetsResult['data'];

        if (data is Map && data.containsKey('data')) {
          final budgetsList = data['data'];
          if (budgetsList is List) {
            budgets = budgetsList.map((item) {
              if (item is Map) {
                return Map<String, dynamic>.from(item);
              }
              return <String, dynamic>{};
            }).toList();
          }
        } else if (data is List) {
          budgets = data.map((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            }
            return <String, dynamic>{};
          }).toList();
        }
      }

      Map<String, dynamic> summary = {
        'total_budgets': 0,
        'monthly': {'count': 0, 'total_amount': 0},
        'weekly': {'count': 0, 'total_amount': 0},
        'by_category': {},
      };

      if (summaryResult['success']) {
        summary = Map<String, dynamic>.from(summaryResult['data']);
      }

      // Ordenar: mensuales primero, luego semanales
      budgets.sort((a, b) {
        final periodA = a['period']?.toString().toLowerCase() ?? '';
        final periodB = b['period']?.toString().toLowerCase() ?? '';

        if (periodA == 'monthly' && periodB != 'monthly') return -1;
        if (periodA != 'monthly' && periodB == 'monthly') return 1;

        return 0;
      });

      setState(() {
        _budgets = budgets;
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredBudgets() {
    if (_selectedFilter == 'all') {
      return _budgets;
    }
    return _budgets
        .where(
          (budget) =>
              budget['period']?.toString().toLowerCase() == _selectedFilter,
        )
        .toList();
  }

  String _formatAmount(dynamic amount) {
    try {
      final numAmount = double.parse(amount.toString());
      return '\$${numAmount.toStringAsFixed(2)}';
    } catch (e) {
      return '\$0.00';
    }
  }

  Color _getPeriodColor(String? period) {
    switch (period?.toLowerCase()) {
      case 'monthly':
        return Colors.blue;
      case 'weekly':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getPeriodIcon(String? period) {
    switch (period?.toLowerCase()) {
      case 'monthly':
        return Icons.calendar_month;
      case 'weekly':
        return Icons.calendar_view_week;
      default:
        return Icons.calendar_today;
    }
  }

  String _getPeriodLabel(String? period) {
    switch (period?.toLowerCase()) {
      case 'monthly':
        return 'Mensual';
      case 'weekly':
        return 'Semanal';
      default:
        return period ?? 'N/A';
    }
  }

  Future<void> _navigateToCreateBudget() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateBudgetPage()),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _navigateToBudgetDetails(
    String budgetId,
    String categoryName,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BudgetDetailsPage(budgetId: budgetId, categoryName: categoryName),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredBudgets = _getFilteredBudgets();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue[50],
                            foregroundColor: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Presupuestos',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue[50],
                            foregroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Resumen de estadísticas
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total de Presupuestos',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_summary['total_budgets'] ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_summary['monthly']?['count'] ?? 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Mensuales',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.calendar_view_week,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_summary['weekly']?['count'] ?? 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Semanales',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Filtros
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildFilterChip('Todos', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Mensuales', 'monthly'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Semanales', 'weekly'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contador de presupuestos filtrados
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mis Presupuestos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${filteredBudgets.length} presupuestos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Lista de presupuestos
                  Expanded(
                    child: filteredBudgets.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.account_balance_wallet,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay presupuestos registrados',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Crea tu primer presupuesto',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _navigateToCreateBudget,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Crear Presupuesto'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                100,
                              ),
                              itemCount: filteredBudgets.length,
                              itemBuilder: (context, index) {
                                final budget = filteredBudgets[index];
                                final budgetId = budget['id']?.toString() ?? '';
                                final amountLimit =
                                    double.tryParse(
                                      budget['amount_limit']?.toString() ?? '0',
                                    ) ??
                                    0;
                                final period =
                                    budget['period']?.toString() ?? '';
                                final categoryData = budget['categories'];
                                final categoryName =
                                    categoryData != null && categoryData is Map
                                    ? categoryData['name']?.toString() ??
                                          'Sin categoría'
                                    : 'Sin categoría';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () => _navigateToBudgetDetails(
                                      budgetId,
                                      categoryName,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: _getPeriodColor(
                                                period,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              _getPeriodIcon(period),
                                              color: _getPeriodColor(period),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  categoryName,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Límite: ${_formatAmount(amountLimit)}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getPeriodColor(
                                                period,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              _getPeriodLabel(period),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: _getPeriodColor(period),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey[400],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: filteredBudgets.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateBudget,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Presupuesto'),
              elevation: 4,
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
