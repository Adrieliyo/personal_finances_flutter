import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Services/account_service.dart';
import '../Services/transaction_service.dart';
import 'creation_pages/create_transaction_page.dart';
import 'creation_pages/create_goal_page.dart';
import 'creation_pages/create_budget_page.dart';
import 'creation_pages/create_category_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _accountService = AccountService();
  final _transactionService = TransactionService();

  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic> _balanceData = {
    'total': 0.0,
    'bank': 0.0,
    'cash': 0.0,
    'credit': 0.0,
    'investment': 0.0,
  };

  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

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
        _accountService.getBalance(),
        _transactionService.getTransactions(),
      ]);

      final balanceResult = results[0];
      final transactionsResult = results[1];

      if (!mounted) return;

      if (balanceResult['success']) {
        final balanceData = balanceResult['data'];
        _balanceData = {
          'total':
              double.tryParse(balanceData['total']?.toString() ?? '0') ?? 0.0,
          'bank':
              double.tryParse(balanceData['bank']?.toString() ?? '0') ?? 0.0,
          'cash':
              double.tryParse(balanceData['cash']?.toString() ?? '0') ?? 0.0,
          'credit':
              double.tryParse(balanceData['credit']?.toString() ?? '0') ?? 0.0,
          'investment':
              double.tryParse(balanceData['investment']?.toString() ?? '0') ??
              0.0,
        };
      }

      if (transactionsResult['success']) {
        final data = transactionsResult['data'];
        List<Map<String, dynamic>> transactions = [];

        if (data is Map && data.containsKey('data')) {
          final transactionsList = data['data'];
          if (transactionsList is List) {
            transactions = transactionsList.map((item) {
              if (item is Map) {
                return Map<String, dynamic>.from(item);
              }
              return <String, dynamic>{};
            }).toList();
          }
        }

        double income = 0.0;
        double expense = 0.0;

        for (var transaction in transactions) {
          final amount =
              double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0.0;
          final type = transaction['type']?.toString().toLowerCase() ?? '';

          if (type == 'income') {
            income += amount;
          } else if (type == 'expense') {
            expense += amount;
          }
        }

        _totalIncome = income;
        _totalExpense = expense;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error al cargar datos: $e';
        _isLoading = false;
      });
    }
  }

  String _formatAmount(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  Future<void> _navigateToPage(Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '¡Bienvenido!',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'EEEE, d MMMM',
                                    'es_ES',
                                  ).format(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.deepPurple[50],
                                foregroundColor: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Balance Total Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.shade400,
                                Colors.deepPurple.shade600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Balance Total',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _formatAmount(_balanceData['total']),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Desglose de cuentas
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    _buildBalanceRow(
                                      'Banco',
                                      _balanceData['bank'],
                                      Icons.account_balance,
                                    ),
                                    const Divider(
                                      color: Colors.white24,
                                      height: 16,
                                    ),

                                    _buildBalanceRow(
                                      'Crédito',
                                      _balanceData['credit'],
                                      Icons.credit_card,
                                    ),
                                    const Divider(
                                      color: Colors.white24,
                                      height: 16,
                                    ),
                                    _buildBalanceRow(
                                      'Inversión',
                                      _balanceData['investment'],
                                      Icons.trending_up,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Ingresos y Gastos
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Ingresos',
                                amount: _totalIncome,
                                icon: Icons.arrow_downward,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                title: 'Gastos',
                                amount: _totalExpense,
                                icon: Icons.arrow_upward,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Acciones Rápidas
                        const Text(
                          'Acciones Rápidas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            _buildQuickActionCard(
                              title: 'Nueva Transacción',
                              icon: Icons.add_card,
                              color: Colors.blue,
                              onTap: () => _navigateToPage(
                                const CreateTransactionPage(),
                              ),
                            ),
                            _buildQuickActionCard(
                              title: 'Nueva Meta',
                              icon: Icons.flag,
                              color: Colors.green,
                              onTap: () =>
                                  _navigateToPage(const CreateGoalPage()),
                            ),
                            _buildQuickActionCard(
                              title: 'Nuevo Presupuesto',
                              icon: Icons.pie_chart,
                              color: Colors.orange,
                              onTap: () =>
                                  _navigateToPage(const CreateBudgetPage()),
                            ),
                            _buildQuickActionCard(
                              title: 'Nueva Categoría',
                              icon: Icons.label,
                              color: Colors.purple,
                              onTap: () =>
                                  _navigateToPage(const CreateCategoryPage()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildBalanceRow(String label, double amount, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        Text(
          _formatAmount(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatAmount(amount),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
