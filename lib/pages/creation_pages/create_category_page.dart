import 'package:flutter/material.dart';
import '../../Services/category_service.dart';

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryService = CategoryService();
  String _selectedType = 'Gastos';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _categoryService.createCategory(
        name: _nameController.text,
        type: _selectedType,
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
        Navigator.pop(context, true); // Retornar true para indicar que se creó
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Nueva Categoría'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre de Categoría
              Text(
                'Nombre de Categoría',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Ej. Alimentación',
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
                    return 'Por favor ingresa un nombre para la categoría';
                  }
                  if (value.length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tipo de Categoría
              Text(
                'Tipo de Categoría',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Gastos'),
                      value: 'expense',
                      groupValue: _selectedType,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedType = value!;
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
                      title: const Text('Ingresos'),
                      value: 'income',
                      groupValue: _selectedType,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedType = value!;
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

              // Botón Agregar Categoría
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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
                          'Agregar Categoría',
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
