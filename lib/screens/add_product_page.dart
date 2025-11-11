import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';
import '../routes/app_routes.dart';
import '../widgets/app_drawer.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _stockController = TextEditingController();
  ProductCategory? _selectedCategory;
  bool _isFeatured = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final product = Product(
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim(),
      thumbnailUrl: _thumbnailController.text.trim(),
      stock: int.parse(_stockController.text.trim()),
      category: _selectedCategory!,
      isFeatured: _isFeatured,
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Produk berhasil disimpan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: product
                  .toDisplayEntries()
                  .map(
                    (entry) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(entry.value),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );

    _resetFormState();
  }

  void _resetFormState() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedCategory = null;
      _isFeatured = false;
    });
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _thumbnailController.clear();
    _stockController.clear();
  }

  String? _validateRequiredText(String? value, {int minLength = 1}) {
    if (value == null || value.trim().isEmpty) {
      return 'Bagian ini wajib diisi.';
    }
    if (value.trim().length < minLength) {
      return 'Minimal $minLength karakter.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Produk Baru',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0AA679),
                Color(0xFF0B8457),
              ],
            ),
          ),
        ),
      ),
      drawer: AppDrawer(
        isOnHome: false,
        isOnAddProduct: true,
        onNavigateHome: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.home),
        onNavigateAddProduct: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.addProduct),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Isi detail produk dengan lengkap untuk menjaga kualitas katalog Football Shop.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  hintText: 'Contoh: Jersey Tim Nasional',
                ),
                validator: (value) => _validateRequiredText(value, minLength: 3),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga (Rp)',
                  hintText: 'Contoh: 249999',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga wajib diisi.';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Masukkan angka yang valid dan lebih besar dari 0.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Tuliskan detail fitur atau cerita produk.',
                ),
                minLines: 3,
                maxLines: 5,
                validator: (value) => _validateRequiredText(value, minLength: 10),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _thumbnailController,
                decoration: const InputDecoration(
                  labelText: 'URL Thumbnail',
                  hintText: 'https://contoh.com/produk.jpg',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  final sanitized = value?.trim() ?? '';
                  final result = _validateRequiredText(sanitized, minLength: 10);
                  if (result != null) return result;
                  final uri = Uri.tryParse(sanitized);
                  final hasValidScheme =
                      uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
                  final hasHost = uri?.host.isNotEmpty ?? false;
                  if (!hasValidScheme || !hasHost) {
                    return 'Masukkan URL http/https yang valid.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  hintText: 'Contoh: 50',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Stok wajib diisi.';
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed < 0) {
                    return 'Masukkan angka bulat minimal 0.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ProductCategory>(
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                ),
                items: ProductCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedCategory = value;
                }),
                validator: (value) =>
                    value == null ? 'Pilih salah satu kategori.' : null,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tandai sebagai produk unggulan'),
                value: _isFeatured,
                onChanged: (value) => setState(() {
                  _isFeatured = value;
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
