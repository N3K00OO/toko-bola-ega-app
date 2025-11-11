enum ProductCategory {
  jersey('Jersey'),
  footwear('Sepatu'),
  accessories('Aksesori'),
  training('Perlengkapan Latihan'),
  memorabilia('Memorabilia');

  const ProductCategory(this.label);
  final String label;
}

class Product {
  const Product({
    required this.name,
    required this.price,
    required this.description,
    required this.thumbnailUrl,
    required this.stock,
    required this.category,
    required this.isFeatured,
  });

  final String name;
  final double price;
  final String description;
  final String thumbnailUrl;
  final int stock;
  final ProductCategory category;
  final bool isFeatured;

  List<MapEntry<String, String>> toDisplayEntries() {
    return [
      MapEntry('Nama Produk', name),
      MapEntry('Harga', 'Rp ${price.toStringAsFixed(0)}'),
      MapEntry('Deskripsi', description),
      MapEntry('URL Thumbnail', thumbnailUrl),
      MapEntry('Stok', stock.toString()),
      MapEntry('Kategori', category.label),
      MapEntry('Featured', isFeatured ? 'Ya' : 'Tidak'),
    ];
  }
}
