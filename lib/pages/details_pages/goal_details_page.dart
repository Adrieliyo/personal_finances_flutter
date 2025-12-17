import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Services/goal_service.dart';
import '../edit_pages/edit_goal_page.dart';

class GoalDetailsPage extends StatefulWidget {
  final String goalId;
  final String goalName;

  const GoalDetailsPage({
    super.key,
    required this.goalId,
    required this.goalName,
  });

  @override
  State<GoalDetailsPage> createState() => _GoalDetailsPageState();
}

class _GoalDetailsPageState extends State<GoalDetailsPage> {
  final _goalService = GoalService();
  final _amountController = TextEditingController();

  Map<String, dynamic>? _goalData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGoalDetails();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadGoalDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _goalService.getGoalById(widget.goalId);

      if (!mounted) return;

      if (result['success']) {
        setState(() {
          _goalData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Error al cargar meta';
          _isLoading = false;
        });
      }
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy', 'es_ES').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _showAddFundsDialog() async {
    _amountController.clear();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Fondos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Agrega dinero a tu meta "${widget.goalName}"',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingresa un monto'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final amount = double.tryParse(_amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingresa un monto válido'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (result == true) {
      final amount = double.parse(_amountController.text);
      await _addFunds(amount);
    }
  }

  Future<void> _showWithdrawFundsDialog() async {
    _amountController.clear();

    final currentAmount =
        double.tryParse(_goalData?['current_amount']?.toString() ?? '0') ?? 0;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirar Fondos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Retira dinero de tu meta "${widget.goalName}"',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Disponible: ${_formatAmount(currentAmount)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingresa un monto'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final amount = double.tryParse(_amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingresa un monto válido'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              if (amount > currentAmount) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No puedes retirar más de lo que tienes'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retirar'),
          ),
        ],
      ),
    );

    if (result == true) {
      final amount = double.parse(_amountController.text);
      await _withdrawFunds(amount);
    }
  }

  Future<void> _addFunds(double amount) async {
    try {
      final result = await _goalService.addFunds(
        goalId: widget.goalId,
        amount: amount,
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        _loadGoalDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _withdrawFunds(double amount) async {
    try {
      final result = await _goalService.withdrawFunds(
        goalId: widget.goalId,
        amount: amount,
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        _loadGoalDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditGoalPage(goalId: widget.goalId, goalData: _goalData!),
      ),
    );

    if (result == true) {
      _loadGoalDetails();
    }
  }

  Future<void> _deleteGoal() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Meta'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${widget.goalName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final result = await _goalService.deleteGoal(widget.goalId);

        if (!mounted) return;

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _goalData == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Error al cargar meta',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadGoalDetails,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final targetAmount =
        double.tryParse(_goalData!['target_amount']?.toString() ?? '0') ?? 0;
    final currentAmount =
        double.tryParse(_goalData!['current_amount']?.toString() ?? '0') ?? 0;
    final remainingAmount =
        double.tryParse(_goalData!['remaining_amount']?.toString() ?? '0') ?? 0;
    final progress =
        double.tryParse(_goalData!['progress']?.toString() ?? '0') ?? 0;
    final deadline = _goalData!['deadline']?.toString() ?? '';
    final daysRemaining = _goalData!['days_remaining'] ?? 0;
    final isOverdue = _goalData!['is_overdue'] == true;
    final isCompleted = _goalData!['is_completed'] == true;
    final status = _goalData!['status']?.toString() ?? 'active';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _navigateToEdit,
                        icon: const Icon(Icons.edit),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: _deleteGoal,
                        icon: const Icon(Icons.delete),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.goalName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _formatAmount(currentAmount),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'de ${_formatAmount(targetAmount)}',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 12,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${progress.toStringAsFixed(1)}% completado',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: status == 'active'
                          ? _showAddFundsDialog
                          : null,
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: status == 'active' && currentAmount > 0
                          ? _showWithdrawFundsDialog
                          : null,
                      icon: const Icon(Icons.remove),
                      label: const Text('Retirar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Detalles
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.trending_up,
                      label: 'Falta por ahorrar',
                      value: _formatAmount(remainingAmount),
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.calendar_today,
                      label: 'Fecha límite',
                      value: _formatDate(deadline),
                      color: isOverdue ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: isOverdue ? Icons.warning : Icons.access_time,
                      label: isOverdue ? 'Vencida' : 'Días restantes',
                      value: isOverdue ? 'Meta vencida' : '$daysRemaining días',
                      color: isOverdue ? Colors.red : Colors.teal,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.flag,
                      label: 'Estado',
                      value: isCompleted
                          ? 'Completada'
                          : status == 'active'
                          ? 'Activa'
                          : status == 'paused'
                          ? 'Pausada'
                          : 'Cancelada',
                      color: isCompleted
                          ? Colors.blue
                          : status == 'active'
                          ? Colors.green
                          : status == 'paused'
                          ? Colors.orange
                          : Colors.red,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
