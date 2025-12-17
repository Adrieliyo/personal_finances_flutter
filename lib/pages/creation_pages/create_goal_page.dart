import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Services/goal_service.dart';

class CreateGoalPage extends StatefulWidget {
  const CreateGoalPage({super.key});

  @override
  State<CreateGoalPage> createState() => _CreateGoalPageState();
}

class _CreateGoalPageState extends State<CreateGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  final _goalService = GoalService();

  DateTime? _selectedDeadline;
  String _selectedStatus = 'active';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 años
      // Remover la línea: locale: const Locale('es', 'ES'),
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

    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDeadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una fecha límite'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final result = await _goalService.createGoal(
        name: _nameController.text,
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: double.parse(
          _currentAmountController.text.isEmpty
              ? '0'
              : _currentAmountController.text,
        ),
        deadline: _formatDateForAPI(_selectedDeadline!),
        status: _selectedStatus,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      // Mostrar mensaje de resultado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      // Si fue exitoso, volver a la página anterior
      if (result['success']) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Nueva Meta'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre de la Meta
              Text(
                'Nombre de la Meta',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Ej. Vacaciones 2026',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre para la meta';
                  }
                  if (value.length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Monto Objetivo
              Text(
                'Monto Objetivo',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _targetAmountController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: 'Ej. 50000',
                  prefixText: '\$ ',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el monto objetivo';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Por favor ingresa un monto válido mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Monto Actual
              Text(
                'Monto Actual (Opcional)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _currentAmountController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: 'Ej. 10000',
                  prefixText: '\$ ',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  helperText: 'Deja en blanco si inicias desde 0',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final currentAmount = double.tryParse(value);
                    if (currentAmount == null || currentAmount < 0) {
                      return 'Por favor ingresa un monto válido';
                    }
                    final targetAmount = double.tryParse(
                      _targetAmountController.text,
                    );
                    if (targetAmount != null && currentAmount > targetAmount) {
                      return 'El monto actual no puede ser mayor al objetivo';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Fecha Límite
              Text(
                'Fecha Límite',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _isLoading ? null : () => _selectDeadline(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: 'Selecciona una fecha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDeadline != null
                        ? _formatDate(_selectedDeadline!)
                        : 'Ej. 15/07/2026',
                    style: TextStyle(
                      color: _selectedDeadline != null
                          ? Colors.black
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Estado
              Text(
                'Estado',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Activa'),
                    selected: _selectedStatus == 'active',
                    onSelected: _isLoading
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() => _selectedStatus = 'active');
                            }
                          },
                    selectedColor: Colors.green[100],
                    checkmarkColor: Colors.green,
                  ),
                  ChoiceChip(
                    label: const Text('Completada'),
                    selected: _selectedStatus == 'completed',
                    onSelected: _isLoading
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() => _selectedStatus = 'completed');
                            }
                          },
                    selectedColor: Colors.blue[100],
                    checkmarkColor: Colors.blue,
                  ),
                  ChoiceChip(
                    label: const Text('Pausada'),
                    selected: _selectedStatus == 'paused',
                    onSelected: _isLoading
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() => _selectedStatus = 'paused');
                            }
                          },
                    selectedColor: Colors.orange[100],
                    checkmarkColor: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botón Agregar Meta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Agregar Meta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
