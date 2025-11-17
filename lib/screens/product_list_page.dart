import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../state/session_state.dart';
import '../widgets/app_drawer.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchController = TextEditingController();
  late Future<List<Product>> _futureProducts;
  bool _mineOnly = true;

  @override
  void initState() {
    super.initState();
    _futureProducts = _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ProductService _service() {
    final request = context.read<CookieRequest>();
    return ProductService(request);
  }

  Future<List<Product>> _fetchProducts() {
    return _service().fetchProducts(
      mineOnly: _mineOnly,
      searchQuery: _searchController.text,
    );
  }

  Future<void> _refresh() async {
    final items = await _fetchProducts();
    if (!mounted) return;
    setState(() {
      _futureProducts = Future.value(items);
    });
  }

  void _applyFilter(bool mineOnly) {
    if (_mineOnly == mineOnly) return;
    setState(() {
      _mineOnly = mineOnly;
      _futureProducts = _fetchProducts();
    });
  }

  void _applySearch() {
    setState(() {
      _futureProducts = _fetchProducts();
    });
  }

  void _openDetail(Product product) {
    Navigator.pushNamed(
      context,
      AppRoutes.productDetail,
      arguments: product,
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Katalog Produk',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
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
      drawer: AppDrawer(
        isOnHome: false,
        isOnAddProduct: false,
        isOnProducts: true,
        onNavigateHome: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.home),
        onNavigateAddProduct: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.addProduct),
        onNavigateProducts: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.products),
        onLogout: _logout,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Cari nama atau brand',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: _applySearch,
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ),
                    onSubmitted: (_) => _applySearch(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilterChip(
                        label: const Text('Semua Produk'),
                        selected: !_mineOnly,
                        onSelected: (_) => _applyFilter(false),
                        selectedColor: colorScheme.primaryContainer,
                      ),
                      const SizedBox(width: 12),
                      FilterChip(
                        label: const Text('Produk Saya'),
                        selected: _mineOnly,
                        onSelected: (_) => _applyFilter(true),
                        selectedColor: colorScheme.secondaryContainer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _futureProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Gagal memuat data.',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () =>
                                setState(() => _futureProducts = _fetchProducts()),
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data ?? [];
                  if (data.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Icon(Icons.inbox_outlined, size: 72, color: Colors.grey),
                          SizedBox(height: 16),
                          Center(
                            child: Text(
                              'Belum ada produk dalam filter ini.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final product = data[index];
                        return ProductCard(
                          product: product,
                          onTap: () => _openDetail(product),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final heroTag = product.id ?? product.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'product-$heroTag',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: product.thumbnailUrl.isEmpty
                        ? Container(
                            width: 88,
                            height: 88,
                            color: colorScheme.primaryContainer,
                            child: const Icon(Icons.image_not_supported),
                          )
                        : Image.network(
                            product.thumbnailUrl,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 88,
                              height: 88,
                              color: colorScheme.primaryContainer,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product.categoryLabel,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (product.isFeatured)
                            Icon(Icons.star, color: colorScheme.secondary, size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.brand,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.formattedPrice,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (!product.isOwner)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Milik: ${product.ownerName ?? product.ownerUsername ?? '-'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


