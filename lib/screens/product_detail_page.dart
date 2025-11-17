import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, this.product});

  final Product? product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<Product> _futureProduct;

  @override
  void initState() {
    super.initState();
    _futureProduct = _loadProduct();
  }

  Future<Product> _loadProduct() {
    final initial = widget.product;
    if (initial == null) {
      return Future<Product>.error('Produk tidak ditemukan.');
    }
    if (initial.id == null) {
      return Future.value(initial);
    }
    final service = ProductService(context.read<CookieRequest>());
    return service.fetchDetail(initial.id!);
  }

  @override
  Widget build(BuildContext context) {
    final heroTag = widget.product?.id ?? widget.product?.name ?? '-';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Produk',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0AA679), Color(0xFF0B8457)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Product>(
        future: _futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        setState(() => _futureProduct = _loadProduct()),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }

          final product = snapshot.data ?? widget.product!;

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Hero(
                tag: 'product-$heroTag',
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: product.thumbnailUrl.isEmpty
                      ? Container(
                          color: colorScheme.primaryContainer,
                          child: const Icon(Icons.image_outlined, size: 56),
                        )
                      : Image.network(
                          product.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: colorScheme.primaryContainer,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            product.categoryLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: colorScheme.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Unggulan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Brand ${product.brand}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product.formattedPrice,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _InfoPill(
                          icon: Icons.person_outline,
                          label:
                              'Milik ${product.ownerName ?? product.ownerUsername ?? '-'}',
                        ),
                        _InfoPill(
                          icon: Icons.remove_red_eye_outlined,
                          label: '${product.views} views',
                        ),
                        _InfoPill(
                          icon: Icons.calendar_month_outlined,
                          label: product.createdLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      product.description.isEmpty
                          ? 'Belum ada deskripsi.'
                          : product.description,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    ...product.detailsForDisplay().map(
                      (entry) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(entry.value),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Kembali ke daftar'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}


