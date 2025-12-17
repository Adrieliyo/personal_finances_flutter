import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Services/transaction_service.dart';
import '../../Services/account_service.dart';
import '../../Services/category_service.dart';

class CreateTransactionPage extends StatefulWidget {
  const CreateTransactionPage({super.key});

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _transactionService = TransactionService();
  final _accountService = AccountService();
  final _categoryService = CategoryService();

  String? _selectedAccountId;
  String? _selectedCategoryId;
  String _selectedType = 'expense';
  DateTime? _selectedDate;
  bool _isRecurring = false;
  bool _isLoading = false;
  bool _isLoadingData = true;

  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> _categories = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Future<void> _loadData() async {
  //   if (!mounted) return;

  //   setState(() {
  //     _isLoadingData = true;
  //     _errorMessage = null;
  //   });

  //   try {
  //     // Cargar cuentas y categorías en paralelo
  //     final results = await Future.wait([
  //       _accountService.getAccounts(),
  //       _categoryService.getCategories(),
  //     ]);

  //     final accountsResult = results[0];
  //     final categoriesResult = results[1];

  //     if (!mounted) return;

  //     if (accountsResult['success'] && categoriesResult['success']) {
  //       setState(() {
  //         // Procesar cuentas
  //         final accountsData = accountsResult['data'];
  //         if (accountsData is List) {
  //           _accounts = accountsData
  //               .map((item) => Map<String, dynamic>.from(item))
  //               .toList();
  //         } else {
  //           _accounts = [];
  //         }

  //         // Procesar categorías
  //         final categoriesData = categoriesResult['data'];
  //         if (categoriesData is List) {
  //           _categories = categoriesData
  //               .map((item) => Map<String, dynamic>.from(item))
  //               .toList();
  //         } else {
  //           _categories = [];
  //         }

  //         _isLoadingData = false;
  //       });
  //     } else {
  //       setState(() {
  //         _errorMessage =
  //             accountsResult['message'] ??
  //             categoriesResult['message'] ??
  //             'Error al cargar datos';
  //         _isLoadingData = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (!mounted) return;

  //     setState(() {
  //       _errorMessage = 'Error de conexión: $e';
  //       _isLoadingData = false;
  //     });
  //   }
  // }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
    });

    try {
      // Cargar cuentas y categorías en paralelo
      final results = await Future.wait([
        _accountService.getAccounts(),
        _categoryService.getCategories(),
      ]);

      final accountsResult = results[0];
      final categoriesResult = results[1];

      print('Accounts Result: $accountsResult'); // Debug
      print('Categories Result: $categoriesResult'); // Debug

      if (!mounted) return;

      if (accountsResult['success'] && categoriesResult['success']) {
        setState(() {
          // Procesar cuentas - la estructura es data.data
          final accountsData = accountsResult['data'];
          if (accountsData is Map && accountsData.containsKey('data')) {
            final accountsList = accountsData['data'];
            if (accountsList is List) {
              _accounts = accountsList.map((item) {
                if (item is Map) {
                  return Map<String, dynamic>.from(item);
                }
                return <String, dynamic>{};
              }).toList();
            }
          } else {
            _accounts = [];
          }

          // Procesar categorías - la estructura es data.data
          final categoriesData = categoriesResult['data'];
          if (categoriesData is Map && categoriesData.containsKey('data')) {
            final categoriesList = categoriesData['data'];
            if (categoriesList is List) {
              _categories = categoriesList.map((item) {
                if (item is Map) {
                  return Map<String, dynamic>.from(item);
                }
                return <String, dynamic>{};
              }).toList();
            }
          } else {
            _categories = [];
          }

          print('Processed Accounts: ${_accounts.length}'); // Debug
          print('Processed Categories: ${_categories.length}'); // Debug

          // Verificar si hay datos
          if (_accounts.isEmpty) {
            _errorMessage =
                'No hay cuentas disponibles. Por favor crea una cuenta primero.';
          } else if (_categories.isEmpty) {
            _errorMessage =
                'No hay categorías disponibles. Por favor crea categorías primero.';
          }

          _isLoadingData = false;
        });
      } else {
        setState(() {
          _errorMessage =
              accountsResult['message'] ??
              categoriesResult['message'] ??
              'Error al cargar datos';
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e'); // Debug
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error de conexión: $e';
        _isLoadingData = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredCategories {
    return _categories.where((category) {
      final categoryType = category['type']?.toString().toLowerCase();
      return categoryType == _selectedType;
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _getColorForType(_selectedType),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'income':
        return Colors.green;
      case 'expense':
        return Colors.red;
      case 'transfer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'income':
        return 'Ingreso';
      case 'expense':
        return 'Gasto';
      case 'transfer':
        return 'Transferencia';
      default:
        return type;
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una cuenta'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una categoría'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una fecha'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final result = await _transactionService.createTransaction(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId!,
          amount: double.parse(_amountController.text),
          date: _formatDateForAPI(_selectedDate!),
          description: _descriptionController.text,
          type: _selectedType,
          isRecurring: _isRecurring,
        );

        if (!mounted) return;

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );

        if (result['success']) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (!mounted) return;

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear transacción: $e'),
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
        title: const Text('Nueva Transacción'),
        backgroundColor: _getColorForType(_selectedType),
      ),
      body: _isLoadingData
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando datos...'),
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
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de Transacción
                    Text(
                      'Tipo de Transacción',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Gasto'),
                          selected: _selectedType == 'expense',
                          onSelected: _isLoading
                              ? null
                              : (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedType = 'expense';
                                      _selectedCategoryId = null;
                                    });
                                  }
                                },
                          selectedColor: Colors.red[100],
                          checkmarkColor: Colors.red,
                          avatar: _selectedType == 'expense'
                              ? null
                              : Icon(
                                  Icons.remove_circle_outline,
                                  size: 18,
                                  color: Colors.red[700],
                                ),
                        ),
                        ChoiceChip(
                          label: const Text('Ingreso'),
                          selected: _selectedType == 'income',
                          onSelected: _isLoading
                              ? null
                              : (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedType = 'income';
                                      _selectedCategoryId = null;
                                    });
                                  }
                                },
                          selectedColor: Colors.green[100],
                          checkmarkColor: Colors.green,
                          avatar: _selectedType == 'income'
                              ? null
                              : Icon(
                                  Icons.add_circle_outline,
                                  size: 18,
                                  color: Colors.green[700],
                                ),
                        ),
                        ChoiceChip(
                          label: const Text('Transferencia'),
                          selected: _selectedType == 'transfer',
                          onSelected: _isLoading
                              ? null
                              : (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedType = 'transfer';
                                      _selectedCategoryId = null;
                                    });
                                  }
                                },
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue,
                          avatar: _selectedType == 'transfer'
                              ? null
                              : Icon(
                                  Icons.swap_horiz,
                                  size: 18,
                                  color: Colors.blue[700],
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Cuenta
                    Text(
                      'Cuenta',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_accounts.isEmpty && !_isLoadingData)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('No hay cuentas disponibles'),
                            ),
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedAccountId,
                        decoration: InputDecoration(
                          hintText: 'Selecciona una cuenta',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: _accounts.map((account) {
                          // Imprimir para debug
                          print('Account item: $account');

                          // Intentar diferentes formatos de ID
                          String? accountId;
                          if (account.containsKey('id')) {
                            accountId = account['id']?.toString();
                          } else if (account.containsKey('_id')) {
                            accountId = account['_id']?.toString();
                          } else if (account.containsKey('account_id')) {
                            accountId = account['account_id']?.toString();
                          }

                          String accountName =
                              account['name']?.toString() ??
                              account['account_name']?.toString() ??
                              'Sin nombre';

                          return DropdownMenuItem<String>(
                            value: accountId ?? '',
                            child: Text(accountName),
                          );
                        }).toList(),
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedAccountId = value;
                                });
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona una cuenta';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 24),

                    // Categoría
                    Text(
                      'Categoría',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_filteredCategories.isEmpty && !_isLoadingData)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No hay categorías de tipo "${_getTypeLabel(_selectedType)}" disponibles',
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
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
                        items: _filteredCategories.map((category) {
                          // Imprimir para debug
                          print('Category item: $category');

                          // Intentar diferentes formatos de ID
                          String? categoryId;
                          if (category.containsKey('id')) {
                            categoryId = category['id']?.toString();
                          } else if (category.containsKey('_id')) {
                            categoryId = category['_id']?.toString();
                          } else if (category.containsKey('category_id')) {
                            categoryId = category['category_id']?.toString();
                          }

                          String categoryName =
                              category['name']?.toString() ??
                              category['category_name']?.toString() ??
                              'Sin nombre';

                          return DropdownMenuItem<String>(
                            value: categoryId ?? '',
                            child: Text(categoryName),
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

                    // Monto
                    Text(
                      'Monto',
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
                        hintText: 'Ej. 1500',
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

                    // Fecha
                    Text(
                      'Fecha',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _isLoading ? null : () => _selectDate(context),
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
                          _selectedDate != null
                              ? _formatDate(_selectedDate!)
                              : 'Ej. 14/12/2025',
                          style: TextStyle(
                            color: _selectedDate != null
                                ? Colors.black
                                : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Descripción
                    Text(
                      'Descripción',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !_isLoading,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Ej. Compra de supermercado',
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
                          return 'Por favor ingresa una descripción';
                        }
                        if (value.length < 3) {
                          return 'La descripción debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Transacción Recurrente
                    Row(
                      children: [
                        Checkbox(
                          value: _isRecurring,
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _isRecurring = value ?? false;
                                  });
                                },
                        ),
                        Expanded(
                          child: Text(
                            'Transacción recurrente',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getColorForType(_selectedType),
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
                            : Text(
                                'Guardar ${_getTypeLabel(_selectedType)}',
                                style: const TextStyle(
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
