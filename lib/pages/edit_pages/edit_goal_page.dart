import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Services/goal_service.dart';

class EditGoalPage extends StatefulWidget {
  final String goalId;
  final Map<String, dynamic> goalData;

  const EditGoalPage({super.key, required this.goalId, required this.goalData});

  @override
  State<EditGoalPage> createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _goalService = GoalService();

  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  DateTime? _selectedDate;
  String _selectedStatus = 'active';
  bool _isLoading = false;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'active', 'label': 'Activa'},
    {'value': 'paused', 'label': 'Pausada'},
    {'value': 'completed', 'label': 'Completada'},
    {'value': 'cancelled', 'label': 'Cancelada'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.goalData['name']?.toString() ?? '',
    );
    _targetAmountController = TextEditingController(
      text: widget.goalData['target_amount']?.toString() ?? '',
    );
    _selectedStatus = widget.goalData['status']?.toString() ?? 'active';

    if (widget.goalData['deadline'] != null) {
      try {
        _selectedDate = DateTime.parse(widget.goalData['deadline'].toString());
      } catch (e) {
        _selectedDate = null;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una fecha límite'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _goalService.updateGoal(
        goalId: widget.goalId,
        name: _nameController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text),
        deadline: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        status: _selectedStatus,
      );

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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Meta',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono y título
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.flag,
                          size: 48,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Actualiza tu meta',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Modifica los detalles de tu meta',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Nombre de la meta
                const Text(
                  'Nombre de la Meta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Ej: Vacaciones 2025',
                    prefixIcon: Icon(Icons.label, color: Colors.green[700]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.green[700]!,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el nombre de la meta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Monto objetivo
                const Text(
                  'Monto Objetivo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _targetAmountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: Colors.green[700],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.green[700]!,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el monto objetivo';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Por favor ingresa un monto válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Fecha límite
                const Text(
                  'Fecha Límite',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.green[700]),
                        const SizedBox(width: 16),
                        Text(
                          _selectedDate == null
                              ? 'Seleccionar fecha'
                              : DateFormat(
                                  'dd/MM/yyyy',
                                  'es_ES',
                                ).format(_selectedDate!),
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedDate == null
                                ? Colors.grey[600]
                                : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Estado
                const Text(
                  'Estado de la Meta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.green[700],
                      ),
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status['value'],
                          child: Row(
                            children: [
                              Icon(
                                status['value'] == 'active'
                                    ? Icons.flag
                                    : status['value'] == 'paused'
                                    ? Icons.pause_circle
                                    : status['value'] == 'completed'
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: status['value'] == 'active'
                                    ? Colors.green
                                    : status['value'] == 'paused'
                                    ? Colors.orange
                                    : status['value'] == 'completed'
                                    ? Colors.blue
                                    : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(status['label']!),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedStatus = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Información actual
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Información Actual',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Monto actual:'),
                          Text(
                            '\$${widget.goalData['current_amount']?.toString() ?? '0.00'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Progreso:'),
                          Text(
                            '${widget.goalData['progress']?.toString() ?? '0'}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Botón de actualizar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Actualizar Meta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
