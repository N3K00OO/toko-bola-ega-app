import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../state/session_state.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final authService = context.read<AuthService>();
    final session = context.read<SessionState>();
    final messenger = ScaffoldMessenger.of(context);
    await authService.logout();
    session.clear();
    if (!context.mounted) return;
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
    final session = context.watch<SessionState>();
    final user = session.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Toko Bola Ega',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0AA679), Color(0xFF0B8457)],
            ),
          ),
        ),
      ),
      drawer: AppDrawer(
        isOnHome: true,
        isOnAddProduct: false,
        isOnProducts: false,
        onNavigateHome: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.home),
        onNavigateAddProduct: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.addProduct),
        onNavigateProducts: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.products),
        onLogout: () => _handleLogout(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Expanded(
                  child: InfoCard(label: 'NPM', value: '2406434153'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InfoCard(label: 'Nama', value: 'Gregorius Ega A. S.'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InfoCard(label: 'Kelas', value: 'PBP C'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    label: 'Username',
                    value: user?.username ?? '-',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InfoCard(
                    label: 'Nama pengguna',
                    value: user?.name ?? 'Belum diisi',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InfoCard(
                    label: 'Last login',
                    value: user?.lastLogin ?? 'Baru saja',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            const Text(
              'Dashboard inventori sepak bola modern',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pantau koleksi jersey, atur stok perlengkapan latihan, dan kurasi produk unggulanmu.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            Row(
              children: [
                Expanded(
                  child: HomeActionCard(
                    icon: Icons.store_outlined,
                    title: 'Katalog',
                    subtitle: 'Lihat inventori terbaru',
                    gradientColors: const [
                      Color(0xFF00A3FF),
                      Color(0xFF0063F7),
                    ],
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.products),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: HomeActionCard(
                    icon: Icons.add_circle_outline,
                    title: 'Tambah Produk',
                    subtitle: 'Input stok baru toko',
                    gradientColors: const [
                      Color(0xFF0BB07B),
                      Color(0xFF045D56),
                    ],
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.addProduct),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: HomeActionCard(
                    icon: Icons.logout,
                    title: 'Keluar',
                    subtitle: 'Akhiri sesi amanmu',
                    gradientColors: const [
                      Color(0xFFFF8E53),
                      Color(0xFFFE6B8B),
                    ],
                    onTap: () => _handleLogout(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class HomeActionCard extends StatelessWidget {
  const HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withValues(alpha: 0.32),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, size: 22, color: Colors.white),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

