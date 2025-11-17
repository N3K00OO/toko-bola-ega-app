import 'dart:convert';

import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../config/app_config.dart';
import '../models/product.dart';

class ProductService {
  ProductService(this.request);
  final CookieRequest request;

  Future<List<Product>> fetchProducts({
    bool mineOnly = true,
    String? searchQuery,
  }) async {
    var uri = Uri.parse(AppConfig.api('/api/products/'));
    final params = <String, String>{};
    if (mineOnly) params['mine'] = '1';
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      params['q'] = searchQuery.trim();
    }
    if (params.isNotEmpty) {
      uri = uri.replace(queryParameters: params);
    }

    final response = await request
        .get(uri.toString())
        .timeout(AppConfig.networkTimeout);
    if (response is! Map || response['ok'] != true) {
      throw Exception('Gagal memuat data produk');
    }
    final items = response['items'] as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList(growable: false);
  }

  Future<Product> fetchDetail(String id, {bool trackView = true}) async {
    var uri = Uri.parse(AppConfig.api('/api/products/$id/'));
    if (trackView) {
      uri = uri.replace(queryParameters: {'track': '1'});
    }
    final response = await request
        .get(uri.toString())
        .timeout(AppConfig.networkTimeout);
    if (response is! Map || response['ok'] != true) {
      throw Exception('Produk tidak ditemukan');
    }
    final item = response['item'];
    if (item is! Map<String, dynamic>) {
      throw Exception('Data produk tidak valid');
    }
    return Product.fromJson(item);
  }

  Future<Product> createProduct(Product draft) async {
    final response = await request
        .postJson(
          AppConfig.api('/api/products/'),
          jsonEncode(draft.toPayload()),
        )
        .timeout(AppConfig.networkTimeout);
    if (response is! Map || response['ok'] != true) {
      final errors = response['errors'];
      if (errors is Map) {
        final firstError = errors.values
            .whereType<List>()
            .expand((element) => element)
            .firstOrNull;
        throw Exception(firstError?.toString() ?? 'Form tidak valid');
      }
      throw Exception('Form tidak valid');
    }

    final item = response['item'];
    if (item is! Map<String, dynamic>) {
      throw Exception('Respons server tidak valid');
    }
    return Product.fromJson(item);
  }
}

extension _IterableExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
