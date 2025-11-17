import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'models/product.dart';
import 'routes/app_routes.dart';
import 'screens/add_product_page.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/product_detail_page.dart';
import 'screens/product_list_page.dart';
import 'screens/register_page.dart';
import 'services/auth_service.dart';
import 'state/session_state.dart';

void main() {
  runApp(const FootballShopApp());
}

class FootballShopApp extends StatelessWidget {
  const FootballShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.light().textTheme;

    return MultiProvider(
      providers: [
        Provider(create: (_) => CookieRequest()),
        ChangeNotifierProvider(create: (_) => SessionState()),
        ProxyProvider<CookieRequest, AuthService>(
          update: (_, request, previous) {
            if (previous != null && identical(previous.request, request)) {
              return previous;
            }
            previous?.dispose();
            return AuthService(request);
          },
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'Toko Bola Ega',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0B8457),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F6FA),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          textTheme: baseTextTheme.apply(
            bodyColor: const Color(0xFF0C1B33),
            displayColor: const Color(0xFF0C1B33),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE0E3EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF0B8457),
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.register: (_) => const RegisterPage(),
          AppRoutes.home: (_) => const HomePage(),
          AppRoutes.products: (_) => const ProductListPage(),
          AppRoutes.addProduct: (_) => const AddProductPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.productDetail) {
            final product = settings.arguments as Product?;
            return MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: product),
            );
          }
          return null;
        },
      ),
    );
  }
}
