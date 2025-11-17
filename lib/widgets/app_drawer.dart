import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/session_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.isOnHome,
    required this.isOnAddProduct,
    required this.isOnProducts,
    required this.onNavigateHome,
    required this.onNavigateAddProduct,
    required this.onNavigateProducts,
    this.onLogout,
  });

  final bool isOnHome;
  final bool isOnAddProduct;
  final bool isOnProducts;
  final VoidCallback onNavigateHome;
  final VoidCallback onNavigateAddProduct;
  final VoidCallback onNavigateProducts;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = context.watch<SessionState>().user;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toko Bola Ega',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.name ?? user?.username ?? 'Football curator',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kelola katalog produk sepak bola kamu dengan mudah.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Halaman Utama'),
              selected: isOnHome,
              onTap: () {
                Navigator.pop(context);
                if (!isOnHome) {
                  onNavigateHome();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box_outlined),
              title: const Text('Tambah Produk'),
              selected: isOnAddProduct,
              onTap: () {
                Navigator.pop(context);
                if (!isOnAddProduct) {
                  onNavigateAddProduct();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Katalog Produk'),
              selected: isOnProducts,
              onTap: () {
                Navigator.pop(context);
                if (!isOnProducts) {
                  onNavigateProducts();
                }
              },
            ),
            const Spacer(),
            if (onLogout != null)
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red[400]),
                title: const Text('Keluar'),
                textColor: Colors.red[400],
                iconColor: Colors.red[400],
                onTap: () {
                  Navigator.pop(context);
                  onLogout!.call();
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '© 2025 Football Shop',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
