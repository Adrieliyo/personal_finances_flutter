import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Services/debt_service.dart';

class CreateDebtPage extends StatefulWidget {
  const CreateDebtPage({super.key});

  @override
  State<CreateDebtPage> createState() => _CreateDebtPageState();
}

class _CreateDebtPageState extends State<CreateDebtPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _remainingAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _minimumPaymentController = TextEditingController();
  final _dueDayController = TextEditingController();
  final _debtService = DebtService();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _totalAmountController.dispose();
    _remainingAmountController.dispose();
    _interestRateController.dispose();
    _minimumPaymentController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  Future<void> _saveDebt() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _debtService.createDebt(
        name: _nameController.text,
        totalAmount: double.parse(_totalAmountController.text),
        remainingAmount: double.parse(_remainingAmountController.text),
        interestRate: double.parse(_interestRateController.text),
        minimumPayment: double.parse(_minimumPaymentController.text),
        dueDay: int.parse(_dueDayController.text),
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
        title: const Text('Agregar Nueva Deuda'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre de la Deuda
              Text(
                'Nombre de la Deuda',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Ej. Tarjeta de Crédito VISA',
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
                    return 'Por favor ingresa un nombre para la deuda';
                  }
                  if (value.length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Monto Total
              Text(
                'Monto Total',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _totalAmountController,
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
                    return 'Por favor ingresa el monto total';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Por favor ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Monto Restante
              Text(
                'Monto Restante',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _remainingAmountController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: 'Ej. 35000',
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
                    return 'Por favor ingresa el monto restante';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Por favor ingresa un monto válido';
                  }
                  final totalAmount = double.tryParse(
                    _totalAmountController.text,
                  );
                  if (totalAmount != null && amount > totalAmount) {
                    return 'El monto restante no puede ser mayor al total';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tasa de Interés
              Text(
                'Tasa de Interés (%)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _interestRateController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: 'Ej. 24.5',
                  suffixText: '%',
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
                    return 'Por favor ingresa la tasa de interés';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0 || rate > 100) {
                    return 'Por favor ingresa una tasa válida (0-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Pago Mínimo
              Text(
                'Pago Mínimo',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _minimumPaymentController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: 'Ej. 1200',
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
                    return 'Por favor ingresa el pago mínimo';
                  }
                  final payment = double.tryParse(value);
                  if (payment == null || payment <= 0) {
                    return 'Por favor ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Día de Vencimiento
              Text(
                'Día de Vencimiento',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dueDayController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: InputDecoration(
                  hintText: 'Ej. 15',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  helperText: 'Día del mes (1-31)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el día de vencimiento';
                  }
                  final day = int.tryParse(value);
                  if (day == null || day < 1 || day > 31) {
                    return 'Por favor ingresa un día válido (1-31)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón Agregar Deuda
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDebt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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
                          'Agregar Deuda',
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
