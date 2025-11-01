import 'package:flutter_test/flutter_test.dart';
import 'package:toko_bola_ega/main.dart';

void main() {
  testWidgets('HomePage menampilkan aksi utama toko', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TokoBolaApp());

    expect(find.text('Selamat datang di Toko Bola EGA'), findsOneWidget);
    expect(find.text('All Products'), findsOneWidget);
    expect(find.text('My Products'), findsOneWidget);
    expect(find.text('Create Product'), findsOneWidget);
    expect(find.text('Katalog produk unggulan'), findsOneWidget);
  });
}
