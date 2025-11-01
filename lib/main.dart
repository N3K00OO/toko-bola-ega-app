import 'package:flutter/material.dart';

void main() {
  runApp(const TokoBolaApp());
}

class TokoBolaApp extends StatelessWidget {
  const TokoBolaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Bola EGA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color(0xFF1B1D2A),
          displayColor: const Color(0xFF1B1D2A),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final totalStock = _catalog.fold<int>(
      0,
      (value, product) => value + product.stock,
    );
    final totalCategories = _catalog
        .map((product) => product.category)
        .toSet()
        .length;
    final topProduct = _catalog.reduce(
      (prev, next) => next.stock > prev.stock ? next : prev,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Toko Bola EGA'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final gap = 16.0;
              final crossAxisCount = switch (width) {
                >= 1080 => 3,
                >= 720 => 2,
                _ => 1,
              };
              final itemWidth = crossAxisCount == 1
                  ? width
                  : (width - (gap * (crossAxisCount - 1))) / crossAxisCount;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShopHeader(),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: _primaryActions
                        .map(
                          (action) => ShopMenuButton(
                            action: action,
                            onTap: () =>
                                _showActionSnackBar(context, action.message),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      ShopStatisticTile(
                        icon: Icons.inventory_rounded,
                        label: 'Total Produk',
                        value: '${_catalog.length} jenis',
                      ),
                      ShopStatisticTile(
                        icon: Icons.task_alt_rounded,
                        label: 'Stok Aktif',
                        value: '$totalStock item',
                      ),
                      ShopStatisticTile(
                        icon: Icons.star_rate_rounded,
                        label: 'Favorit Fans',
                        value: topProduct.name,
                      ),
                      ShopStatisticTile(
                        icon: Icons.category_rounded,
                        label: 'Kategori',
                        value: '$totalCategories segmen',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Katalog produk unggulan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: _catalog
                        .map(
                          (product) => SizedBox(
                            width: crossAxisCount == 1 ? width : itemWidth,
                            child: ProductCard(product: product),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ShopHeader extends StatelessWidget {
  const ShopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang di Toko Bola EGA',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Temukan perlengkapan sepak bola pilihan untuk mendukung latihan '
              'hingga hari pertandingan. Semua kurasi kami fokus pada performa '
              'dan kenyamanan atlet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer
                    .withAlpha((0.88 * 255).round()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShopMenuButton extends StatelessWidget {
  const ShopMenuButton({super.key, required this.action, required this.onTap});

  final ShopMenuAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180),
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(action.icon),
        label: Text(action.label),
        style: FilledButton.styleFrom(
          backgroundColor: action.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class ShopStatisticTile extends StatelessWidget {
  const ShopStatisticTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 240),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    colorScheme.primary.withAlpha((0.12 * 255).round()),
                child: Icon(icon, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final FootballProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            _showActionSnackBar(context, 'Lihat detail ${product.name}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    product.accentColor.withAlpha((0.16 * 255).round()),
                child: Icon(product.icon, color: product.accentColor, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                product.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.category,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.formattedPrice,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: product.accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  StockBadge(stock: product.stock),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final isHealthy = stock >= 10;
    final backgroundColor = isHealthy
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFF3E0);
    final foregroundColor = isHealthy
        ? const Color(0xFF2E7D32)
        : const Color(0xFFEF6C00);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$stock in stock',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ShopMenuAction {
  const ShopMenuAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.message,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String message;
}

class FootballProduct {
  const FootballProduct({
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.icon,
    required this.accentColor,
    required this.description,
  });

  final String name;
  final String category;
  final int price;
  final int stock;
  final IconData icon;
  final Color accentColor;
  final String description;

  String get formattedPrice => _formatCurrency(price);
}

void _showActionSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

String _formatCurrency(int value) {
  final digits = value.toString();
  final buffer = StringBuffer('Rp ');

  for (var index = 0; index < digits.length; index++) {
    buffer.write(digits[index]);
    final remaining = digits.length - index - 1;
    if (remaining % 3 == 0 && remaining != 0) {
      buffer.write('.');
    }
  }

  return buffer.toString();
}

const List<ShopMenuAction> _primaryActions = [
  ShopMenuAction(
    label: 'All Products',
    icon: Icons.storefront_rounded,
    color: Color(0xFF1976D2),
    message: 'Kamu telah menekan tombol All Products',
  ),
  ShopMenuAction(
    label: 'My Products',
    icon: Icons.favorite_rounded,
    color: Color(0xFF2E7D32),
    message: 'Kamu telah menekan tombol My Products',
  ),
  ShopMenuAction(
    label: 'Create Product',
    icon: Icons.add_circle_rounded,
    color: Color(0xFFC62828),
    message: 'Kamu telah menekan tombol Create Product',
  ),
];

const List<FootballProduct> _catalog = [
  FootballProduct(
    name: 'EGA Official Match Ball',
    category: 'Bola',
    price: 659000,
    stock: 12,
    icon: Icons.sports_soccer,
    accentColor: Color(0xFF1565C0),
    description:
        'Bola pertandingan bersertifikasi FIFA dengan lapisan microtexture '
        'untuk sentuhan yang presisi.',
  ),
  FootballProduct(
    name: 'Phantom Speed Elite',
    category: 'Sepatu',
    price: 2299000,
    stock: 7,
    icon: Icons.directions_run_rounded,
    accentColor: Color(0xFFEF6C00),
    description:
        'Sepatu ringan dengan plate karbon untuk akselerasi maksimal '
        'di setiap sprint.',
  ),
  FootballProduct(
    name: 'Grip Pro Goalkeeper Gloves',
    category: 'Sarung Tangan',
    price: 799000,
    stock: 9,
    icon: Icons.back_hand_rounded,
    accentColor: Color(0xFF2E7D32),
    description:
        'Latex contact foam premium yang tetap lengket dalam segala kondisi '
        'cuaca.',
  ),
  FootballProduct(
    name: 'Elite Training Jersey',
    category: 'Apparel Latihan',
    price: 459000,
    stock: 18,
    icon: Icons.checkroom_rounded,
    accentColor: Color(0xFF8E24AA),
    description:
        'Bahan aero-knit dengan panel ventilasi untuk latihan intens tanpa '
        'mengorbankan kenyamanan.',
  ),
];
