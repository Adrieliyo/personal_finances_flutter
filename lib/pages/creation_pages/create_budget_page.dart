import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Services/budget_service.dart';
import '../../Services/category_service.dart';

class CreateBudgetPage extends StatefulWidget {
  const CreateBudgetPage({super.key});

  @override
  State<CreateBudgetPage> createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends State<CreateBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _budgetService = BudgetService();
  final _categoryService = CategoryService();

  String? _selectedCategoryId;
  String _selectedPeriod = 'monthly';
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  List<Map<String, dynamic>> _categories = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Usar Future.microtask para evitar bloquear la UI
    Future.microtask(() => _loadCategories());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;

    setState(() {
      _isLoadingCategories = true;
      _errorMessage = null;
    });

    try {
      final result = await _categoryService.getCategories();

      print('Result completo: $result'); // Para debugging

      if (!mounted) return;

      if (result['success'] == true) {
        // El backend retorna { success, data: [...], count }
        // Necesitamos acceder a result['data']
        final responseData = result['data'];

        print(
          'Response data type: ${responseData.runtimeType}',
        ); // Para debugging
        print('Response data: $responseData'); // Para debugging

        if (responseData is Map && responseData.containsKey('data')) {
          // Si data es un Map con otra propiedad data dentro
          final categoriesList = responseData['data'];
          if (categoriesList is List) {
            setState(() {
              _categories = categoriesList
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList();
              _isLoadingCategories = false;
            });
          } else {
            setState(() {
              _categories = [];
              _errorMessage = 'Formato de datos incorrecto (data no es lista)';
              _isLoadingCategories = false;
            });
          }
        } else if (responseData is List) {
          // Si data ya es directamente una lista
          setState(() {
            _categories = responseData
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
            _isLoadingCategories = false;
          });
        } else {
          setState(() {
            _categories = [];
            _errorMessage =
                'Formato de datos incorrecto (tipo: ${responseData.runtimeType})';
            _isLoadingCategories = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Error al cargar categorías';
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error de conexión: $e';
        _isLoadingCategories = false;
      });

      print('Error loading categories: $e'); // Para debugging
    }
  }

  Future<void> _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una categoría'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final result = await _budgetService.createBudget(
          categoryId: _selectedCategoryId!,
          amountLimit: double.parse(_amountController.text),
          period: _selectedPeriod,
        );

        if (!mounted) return;

        setState(() => _isLoading = false);

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
      } catch (e) {
        if (!mounted) return;

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear presupuesto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Presupuesto'),
        backgroundColor: Colors.purple,
      ),
      body: _isLoadingCategories
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando categorías...'),
                ],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadCategories,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : _categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay categorías disponibles',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea una categoría primero',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector de Categoría
                    Text(
                      'Categoría',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      decoration: InputDecoration(
                        hintText: 'Selecciona una categoría',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id']?.toString() ?? '',
                          child: Text(
                            category['name']?.toString() ?? 'Sin nombre',
                          ),
                        );
                      }).toList(),
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor selecciona una categoría';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Monto Límite
                    Text(
                      'Monto Límite',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      enabled: !_isLoading,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Ej. 5000',
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
                          return 'Por favor ingresa un monto';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Por favor ingresa un monto válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Período
                    Text(
                      'Período',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Mensual'),
                            value: 'monthly',
                            groupValue: _selectedPeriod,
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedPeriod = value!;
                                    });
                                  },
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Semanal'),
                            value: 'weekly',
                            groupValue: _selectedPeriod,
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedPeriod = value!;
                                    });
                                  },
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Botón Crear Presupuesto
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveBudget,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
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
                                'Crear Presupuesto',
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
