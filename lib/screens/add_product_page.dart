import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../state/session_state.dart';
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
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  ProductCategory? _selectedCategory;
  bool _isFeatured = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Pilih kategori terlebih dahulu.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final service = ProductService(context.read<CookieRequest>());

    final draft = Product(
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim(),
      thumbnailUrl: _thumbnailController.text.trim(),
      category: _selectedCategory!.code,
      isFeatured: _isFeatured,
    );

    try {
      final created = await service.createProduct(draft);
      if (!mounted) return;
      await _showSuccessDialog(created);
      _resetFormState();
    } catch (error) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _resetFormState() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedCategory = null;
      _isFeatured = false;
    });
    _nameController.clear();
    _priceController.clear();
    _brandController.clear();
    _descriptionController.clear();
    _thumbnailController.clear();
  }

  Future<void> _showSuccessDialog(Product product) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Produk berhasil disimpan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: product
                  .detailsForDisplay()
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
  }

  Future<void> _logout() async {
    final authService = context.read<AuthService>();
    final session = context.read<SessionState>();
    final messenger = ScaffoldMessenger.of(context);
    await authService.logout();
    session.clear();
    if (!mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Kamu sudah keluar dari sesi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
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
        isOnProducts: false,
        onNavigateHome: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.home),
        onNavigateAddProduct: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.addProduct),
        onNavigateProducts: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.products),
        onLogout: _logout,
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
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  hintText: 'Contoh: Nike, Adidas',
                  prefixIcon: Icon(Icons.local_mall_outlined),
                ),
                validator: (value) => _validateRequiredText(value, minLength: 2),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga (Rp)',
                  hintText: 'Contoh: 249999',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga wajib diisi.';
                  }
                  final parsed = int.tryParse(value);
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
                  prefixIcon: Icon(Icons.description_outlined),
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
                  prefixIcon: Icon(Icons.image_outlined),
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
              DropdownButtonFormField<ProductCategory>(
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category_outlined),
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
                subtitle: const Text('Produk unggulan akan tampil lebih menonjol.'),
                value: _isFeatured,
                onChanged: (value) => setState(() {
                  _isFeatured = value;
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _handleSave,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSubmitting ? 'Menyimpan...' : 'Simpan Produk',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
