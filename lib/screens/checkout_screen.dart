import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Thanh toán')),
      body: Column(
        children: [
          Text("Tổng tiền: \$${cart.totalPrice.toStringAsFixed(2)}", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Xử lý thanh toán
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Thanh toán thành công!"))
              );
              cart.clearCart();
            },
            child: Text("Thanh toán"),
          ),
        ],
      ),
    );
  }
}
