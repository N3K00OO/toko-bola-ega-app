import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  void _showSnackBar(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Kamu memilih aksi $label'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
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
        onNavigateHome: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.home),
        onNavigateAddProduct: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.addProduct),
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
                  child: InfoCard(label: 'Nama', value: 'G. Ega. A Sudjali'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InfoCard(label: 'Kelas', value: 'C'),
                ),
              ],
            ),
            const SizedBox(height: 36),
            const Text(
              'Selamat datang di Football Shop',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 36),
            Row(
              children: [
                Expanded(
                  child: HomeActionCard(
                    icon: Icons.article_outlined,
                    title: 'Football News',
                    subtitle: 'Lihat kabar & rumor terbaru',
                    gradientColors: const [
                      Color(0xFF00A3FF),
                      Color(0xFF0063F7),
                    ],
                    onTap: () =>
                        _showSnackBar(context, 'Lihat pemberitaan sepak bola'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: HomeActionCard(
                    icon: Icons.add_circle_outline,
                    title: 'Add Product',
                    subtitle: 'Tambahkan stok baru toko',
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
                    title: 'Logout',
                    subtitle: 'Keluar dari sesi anda',
                    gradientColors: const [
                      Color(0xFFFF8E53),
                      Color(0xFFFE6B8B),
                    ],
                    onTap: () => _showSnackBar(context, 'Logout'),
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
