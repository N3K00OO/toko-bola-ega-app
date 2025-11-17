import 'package:intl/intl.dart';

enum ProductCategory {
  jerseys(code: 'jerseys', label: 'Jersey & Apparel'),
  balls(code: 'balls', label: 'Bola Resmi'),
  trainers(code: 'trainers', label: 'Sepatu & Trainers'),
  protectors(code: 'protectors', label: 'Pelindung'),
  clearance(code: 'clearance', label: 'Clearance'),
  misc(code: 'misc', label: 'Kustom');

  const ProductCategory({required this.code, required this.label});
  final String code;
  final String label;

  static ProductCategory? byCode(String? code) {
    if (code == null) return null;
    for (final value in ProductCategory.values) {
      if (value.code == code) return value;
    }
    return null;
  }
}

class Product {
  const Product({
    this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.description,
    required this.thumbnailUrl,
    required this.isFeatured,
    this.createdAt,
    this.views = 0,
    this.isOwner = false,
    this.ownerName,
    this.ownerUsername,
  });

  final String? id;
  final String name;
  final String brand;
  final String category;
  final int price;
  final String description;
  final String thumbnailUrl;
  final bool isFeatured;
  final DateTime? createdAt;
  final int views;
  final bool isOwner;
  final String? ownerName;
  final String? ownerUsername;

  factory Product.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at'] as String?;
    return Product(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '-',
      brand: json['brand'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? 'misc',
      price: (json['price'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnails'] as String? ?? '',
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: createdRaw == null ? null : DateTime.tryParse(createdRaw),
      views: (json['views'] as num?)?.toInt() ?? 0,
      isOwner: json['is_owner'] as bool? ?? false,
      ownerUsername: json['owner_username'] as String?,
      ownerName: json['owner_name'] as String?,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'name': name,
      'brand': brand,
      'category': category,
      'price': price,
      'description': description,
      'thumbnails': thumbnailUrl,
      'is_featured': isFeatured,
    };
  }

  String get formattedPrice =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
          .format(price);

  String get createdLabel {
    if (createdAt == null) return 'Baru dibuat';
    return DateFormat('dd MMM yyyy, HH:mm').format(createdAt!.toLocal());
  }

  ProductCategory? get categoryPreset =>
      ProductCategory.byCode(category.toLowerCase());

  String get categoryLabel =>
      categoryPreset?.label ?? category.toUpperCase();

  List<MapEntry<String, String>> detailsForDisplay() {
    return [
      MapEntry('Nama', name),
      MapEntry('Brand', brand),
      MapEntry('Kategori', categoryLabel),
      MapEntry('Harga', formattedPrice),
      MapEntry('Deskripsi', description),
      MapEntry('Thumbnail', thumbnailUrl),
      MapEntry('Produk Unggulan', isFeatured ? 'Ya' : 'Tidak'),
    ];
  }
}
