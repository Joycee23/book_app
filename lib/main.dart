import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/user_info_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ⚡️ Khởi tạo Firebase

  final authProvider = AuthProvider();
  await authProvider.loadToken(); // Load token & dữ liệu người dùng trước khi chạy app

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MyApp(authProvider),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  MyApp(this.authProvider); // Nhận authProvider từ `main()`

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Store App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSans',
      ),
      home: _getInitialScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/cart': (context) => CartScreen(),
        '/checkout': (context) => CheckoutScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/user_info': (context) => UserInfoScreen(),
      },
    );
  }

  /// Xác định màn hình khởi động dựa vào trạng thái đăng nhập
  Widget _getInitialScreen() {
    if (authProvider.isAuthenticated) {
      if (authProvider.fullName.isNotEmpty) {
        return HomeScreen(); // Đã có thông tin, vào thẳng Home
      } else {
        return UserInfoScreen(); // Chưa có thông tin, vào màn hình cập nhật
      }
    } else {
      return LoginScreen(); // Chưa đăng nhập, vào màn hình đăng nhập
    }
  }
}
