import 'package:flutter/material.dart';
import '../../Services/debt_service.dart';
import '../creation_pages/create_debt_page.dart';
import '../details_pages/debt_details_page.dart';

class DebtsStatisticsPage extends StatefulWidget {
  const DebtsStatisticsPage({super.key});

  @override
  State<DebtsStatisticsPage> createState() => _DebtsStatisticsPageState();
}

class _DebtsStatisticsPageState extends State<DebtsStatisticsPage> {
  final _debtService = DebtService();
  List<Map<String, dynamic>> _debts = [];
  Map<String, dynamic> _summary = {
    'total_debts': 0,
    'total_amount': 0,
    'total_remaining': 0,
    'total_paid': 0,
  };
  bool _isLoading = true;
  String? _errorMessage;

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
        _debtService.getDebts(),
        _debtService.getDebtSummary(),
      ]);

      final debtsResult = results[0];
      final summaryResult = results[1];

      if (!mounted) return;

      List<Map<String, dynamic>> debts = [];

      if (debtsResult['success']) {
        final data = debtsResult['data'];

        if (data is Map && data.containsKey('data')) {
          final debtsList = data['data'];
          if (debtsList is List) {
            debts = debtsList.map((item) {
              if (item is Map) {
                return Map<String, dynamic>.from(item);
              }
              return <String, dynamic>{};
            }).toList();
          }
        } else if (data is List) {
          debts = data.map((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            }
            return <String, dynamic>{};
          }).toList();
        }
      }

      Map<String, dynamic> summary = {
        'total_debts': 0,
        'total_amount': 0,
        'total_remaining': 0,
        'total_paid': 0,
      };

      if (summaryResult['success']) {
        summary = Map<String, dynamic>.from(summaryResult['data']);
      }

      // Ordenar por monto restante (mayor a menor)
      debts.sort((a, b) {
        final remainingA =
            double.tryParse(a['remaining_amount']?.toString() ?? '0') ?? 0;
        final remainingB =
            double.tryParse(b['remaining_amount']?.toString() ?? '0') ?? 0;
        return remainingB.compareTo(remainingA);
      });

      setState(() {
        _debts = debts;
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

  String _formatAmount(dynamic amount) {
    try {
      final numAmount = double.parse(amount.toString());
      return '\$${numAmount.toStringAsFixed(2)}';
    } catch (e) {
      return '\$0.00';
    }
  }

  double _calculateProgress(dynamic total, dynamic remaining) {
    try {
      final totalAmount = double.parse(total.toString());
      final remainingAmount = double.parse(remaining.toString());
      if (totalAmount <= 0) return 0;
      final paid = totalAmount - remainingAmount;
      return (paid / totalAmount * 100);
    } catch (e) {
      return 0;
    }
  }

  Future<void> _navigateToCreateDebt() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateDebtPage()),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _navigateToDebtDetails(String debtId, String debtName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DebtDetailsPage(debtId: debtId, debtName: debtName),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount =
        double.tryParse(_summary['total_amount']?.toString() ?? '0') ?? 0;
    final totalRemaining =
        double.tryParse(_summary['total_remaining']?.toString() ?? '0') ?? 0;
    final totalPaid = totalAmount - totalRemaining;
    final overallProgress = totalAmount > 0
        ? (totalPaid / totalAmount * 100)
        : 0;

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
                          backgroundColor: Colors.red,
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
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Mis Deudas',
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
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Resumen general
                  // Container(
                  //   margin: const EdgeInsets.symmetric(horizontal: 20),
                  //   padding: const EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       colors: [Colors.red.shade400, Colors.red.shade600],
                  //       begin: Alignment.topLeft,
                  //       end: Alignment.bottomRight,
                  //     ),
                  //     borderRadius: BorderRadius.circular(16),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.red.withOpacity(0.3),
                  //         blurRadius: 8,
                  //         offset: const Offset(0, 4),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       const Text(
                  //         'Progreso Total de Pago',
                  //         style: TextStyle(
                  //           color: Colors.white70,
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.w500,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 8),
                  //       Text(
                  //         '${overallProgress.toStringAsFixed(1)}%',
                  //         style: const TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 32,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 16),
                  //       ClipRRect(
                  //         borderRadius: BorderRadius.circular(10),
                  //         child: LinearProgressIndicator(
                  //           value: overallProgress / 100,
                  //           minHeight: 8,
                  //           backgroundColor: Colors.white.withOpacity(0.3),
                  //           valueColor: const AlwaysStoppedAnimation<Color>(
                  //             Colors.white,
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(height: 16),
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               const Text(
                  //                 'Pagado',
                  //                 style: TextStyle(
                  //                   color: Colors.white70,
                  //                   fontSize: 12,
                  //                 ),
                  //               ),
                  //               Text(
                  //                 _formatAmount(totalPaid),
                  //                 style: const TextStyle(
                  //                   color: Colors.white,
                  //                   fontSize: 16,
                  //                   fontWeight: FontWeight.bold,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //           Column(
                  //             crossAxisAlignment: CrossAxisAlignment.end,
                  //             children: [
                  //               const Text(
                  //                 'Restante',
                  //                 style: TextStyle(
                  //                   color: Colors.white70,
                  //                   fontSize: 12,
                  //                 ),
                  //               ),
                  //               Text(
                  //                 _formatAmount(totalRemaining),
                  //                 style: const TextStyle(
                  //                   color: Colors.white,
                  //                   fontSize: 16,
                  //                   fontWeight: FontWeight.bold,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 20),

                  // Estadísticas rápidas
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            label: 'Total Deudas',
                            value: '${_summary['total_debts'] ?? 0}',
                            icon: Icons.credit_card,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            label: 'Monto Total',
                            value: _formatAmount(_summary['total_amount']),
                            icon: Icons.attach_money,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lista de deudas
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mis Deudas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${_debts.length} deudas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: _debts.isEmpty
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
                                    Icons.credit_card,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay deudas registradas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '¡Excelente! No tienes deudas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _navigateToCreateDebt,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Registrar Deuda'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
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
                              itemCount: _debts.length,
                              itemBuilder: (context, index) {
                                final debt = _debts[index];
                                final debtId = debt['id']?.toString() ?? '';
                                final name =
                                    debt['name']?.toString() ?? 'Sin nombre';
                                final totalAmount =
                                    double.tryParse(
                                      debt['total_amount']?.toString() ?? '0',
                                    ) ??
                                    0;
                                final remainingAmount =
                                    double.tryParse(
                                      debt['remaining_amount']?.toString() ??
                                          '0',
                                    ) ??
                                    0;
                                final interestRate =
                                    double.tryParse(
                                      debt['interest_rate']?.toString() ?? '0',
                                    ) ??
                                    0;
                                final minimumPayment =
                                    double.tryParse(
                                      debt['minimum_payment']?.toString() ??
                                          '0',
                                    ) ??
                                    0;
                                final dueDay = debt['due_day'] ?? 0;
                                final progress = _calculateProgress(
                                  totalAmount,
                                  remainingAmount,
                                );

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
                                    onTap: () =>
                                        _navigateToDebtDetails(debtId, name),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Nombre y estado
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(
                                                    0.1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.credit_card,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),

                                          // Progreso
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _formatAmount(remainingAmount),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              Text(
                                                '${progress.toStringAsFixed(1)}% pagado',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: progress / 100,
                                              minHeight: 8,
                                              backgroundColor: Colors.grey[200],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    progress >= 100
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Información adicional
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.payments,
                                                          size: 14,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Pago mín: ${_formatAmount(minimumPayment)}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.percent,
                                                          size: 14,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Interés: ${interestRate.toStringAsFixed(2)}%',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.calendar_today,
                                                        size: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Día $dueDay',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.flag_outlined,
                                                        size: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Total: ${_formatAmount(totalAmount)}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
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
      floatingActionButton: _debts.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateDebt,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nueva Deuda'),
              elevation: 4,
            )
          : null,
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: value.length > 10 ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
