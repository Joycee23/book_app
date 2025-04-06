import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _token = "";
  String? _email;
  String _fullName = ""; 
  String _phoneNumber = ""; 
  String _address = ""; 

  bool get isAuthenticated => _token.isNotEmpty;
  String? get email => _email;
  String get fullName => _fullName;
  String get phoneNumber => _phoneNumber;
  String get address => _address;

  /// Kiểm tra xem có thông tin đầy đủ không
  bool get hasUserInfo {
    return _fullName.isNotEmpty && _phoneNumber.isNotEmpty && _address.isNotEmpty;
  }

  /// Lưu token vào SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Tải token và thông tin người dùng từ SharedPreferences
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token') ?? "";
    _email = prefs.getString('email');
    _fullName = prefs.getString('full_name') ?? "";
    _phoneNumber = prefs.getString('phone_number') ?? "";
    _address = prefs.getString('address') ?? "";
    notifyListeners();
  }

  /// Hàm công khai để load dữ liệu khi app khởi động
  Future<void> loadToken() async {
    await _loadToken();
  }

  /// Đăng xuất (Chỉ xóa token, giữ lại thông tin người dùng)
  Future<void> logout() async {
    _token = "";
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Chỉ xóa token, không xóa thông tin user
    notifyListeners();
  }

  /// Cập nhật thông tin người dùng vào Firestore và SharedPreferences
  Future<void> updateUserInfo({
    required String email,
    required String fullName,
    required String phoneNumber,
    required String address,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    _email = email;
    _fullName = fullName;
    _phoneNumber = phoneNumber;
    _address = address;

    // ✅ Cập nhật thông tin theo email (SetOptions(merge: true) để tránh mất dữ liệu cũ)
    await _firestore.collection('users').doc(email).set({
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
    }, SetOptions(merge: true));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('full_name', fullName);
    await prefs.setString('phone_number', phoneNumber);
    await prefs.setString('address', address);

    notifyListeners();
  }

  /// Đăng ký tài khoản
  Future<String> register(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String token = (await userCredential.user?.getIdToken()) ?? "";
      _token = token;

      // 🌟 Cập nhật lại cách lưu dữ liệu vào Firestore
      await _firestore.collection('users').doc(userCredential.user!.email).set({
        'email': email,
        'fullName': '',
        'phoneNumber': '',
        'address': '',
      });

      await _saveToken(token);
      notifyListeners();

      Navigator.pushReplacementNamed(context, '/login');
      return "Đăng ký thành công!";
    } catch (e) {
      return "Lỗi: ${e.toString()}";
    }
  }

  /// Đăng nhập, ưu tiên lấy dữ liệu từ SharedPreferences trước
  Future<String> login(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String? token = await userCredential.user?.getIdToken();
      if (token == null || token.isEmpty) {
        return "Lỗi xác thực, vui lòng thử lại!";
      }

      _token = token;
      _email = email;

      final prefs = await SharedPreferences.getInstance();
      
      // Kiểm tra nếu dữ liệu có trong SharedPreferences
      if (prefs.containsKey('full_name')) {
        _fullName = prefs.getString('full_name') ?? "";
        _phoneNumber = prefs.getString('phone_number') ?? "";
        _address = prefs.getString('address') ?? "";
      } else {
        // Nếu chưa có, lấy từ Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.email).get();
        if (!userDoc.exists) {
          return "Sai email hoặc mật khẩu!";
        }

        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        _fullName = userData?['fullName'] ?? "";
        _phoneNumber = userData?['phoneNumber'] ?? "";
        _address = userData?['address'] ?? "";

        // Lưu vào SharedPreferences
        await prefs.setString('full_name', _fullName);
        await prefs.setString('phone_number', _phoneNumber);
        await prefs.setString('address', _address);
      }
      
      await _saveToken(token);
      notifyListeners();

      Navigator.pushReplacementNamed(context, '/user_info');
      return "Đăng nhập thành công!";
    } catch (e) {
      return "Sai email hoặc mật khẩu!";
    }
  }
}
