import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _acceptTerms = false;

  void _register() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bạn phải chấp nhận điều khoản và điều kiện!")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mật khẩu không khớp!")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    String message = await auth.register(_emailController.text, _passwordController.text, context);
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🌟 Đổi nền sang trắng
      appBar: AppBar(
        title: const Text("Đăng ký tài khoản"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle("Email"),
            _buildTextField(_emailController, "Nhập email của bạn", TextInputType.emailAddress, false),
            _buildTitle("Mật khẩu"),
            _buildTextField(_passwordController, "Nhập mật khẩu", TextInputType.text, true),
            _buildTitle("Xác nhận mật khẩu"),
            _buildTextField(_confirmPasswordController, "Nhập lại mật khẩu", TextInputType.text, true),
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (value) => setState(() => _acceptTerms = value!),
                  activeColor: Colors.blueAccent,
                ),
                const Text("Tôi đồng ý với ", style: TextStyle(fontSize: 14)),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Điều khoản & Điều kiện",
                    style: TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _register,
                      child: const Text("Đăng ký", style: TextStyle(fontSize: 16)),
                    ),
                  ),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text("Đã có tài khoản? Đăng nhập", style: TextStyle(fontSize: 14, color: Colors.blueAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Tiêu đề cho từng mục nhập
  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent),
      ),
    );
  }

  /// 🔹 Ô nhập liệu với thiết kế đẹp hơn
  Widget _buildTextField(TextEditingController controller, String hint, TextInputType keyboardType, bool isPassword) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
