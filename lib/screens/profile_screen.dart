import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_app/providers/auth_provider.dart';
import 'dart:math';

class ProfileScreen extends StatelessWidget {
  final List<String> avatarUrls = [
    'https://i.pravatar.cc/150?img=1',
    'https://i.pravatar.cc/150?img=2',
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=4',
    'https://i.pravatar.cc/150?img=5',
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final randomAvatar = avatarUrls[Random().nextInt(avatarUrls.length)];

    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin cá nhân")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(randomAvatar),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard("Email", authProvider.email ?? "Chưa có"),
            _buildInfoCard("Họ và tên", authProvider.fullName ?? "Chưa có"),
            _buildInfoCard("Số điện thoại", authProvider.phoneNumber ?? "Chưa có"),
            _buildInfoCard("Địa chỉ nhận hàng", authProvider.address ?? "Chưa có"),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, "/login");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Đăng Xuất", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
