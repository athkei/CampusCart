import 'package:flutter/material.dart';
import '../common.dart';
import '../models/cart_item.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';

/// Order Summary: a read-only review of what the student is about to order.
/// Shows each item, quantity, price, and the computed total.
class OrderSummaryPage extends StatelessWidget {
  const OrderSummaryPage({super.key});

  // ---------------------------------------------------------------------
  // TODO (checkout teammate - Athena): connect this button to checkout.
  // You can use:
  //   CartService.toOrderItems()  -> list of items (foodId, name, price,
  //                                  quantity, subtotal) to save in Firestore
  //   CartService.totalPrice      -> the order total
  //   CartService.totalQuantity   -> total number of pieces
  //   AuthService().currentUser   -> the logged-in student (uid, email)
  // After the order is saved, call CartService.clear() to empty the cart.
  // Right now the button is a placeholder and does NOT create an order.
  // ---------------------------------------------------------------------
  void _proceedToCheckout(BuildContext context) {
    showMsg(context, 'Checkout is not connected yet.');
  }

  @override
  Widget build(BuildContext context) {
    final items = CartService.items;
    final email = AuthService().currentUser?.email ?? 'Unknown student';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: const IconThemeData(color: ink),
        title: const Text('Order Summary',
            style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
      ),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: blushPink,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Details',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: ink)),
                        const SizedBox(height: 6),
                        Text('Ordered by: $email',
                            style: const TextStyle(color: ink)),
                        const SizedBox(height: 2),
                        const Text('Type: Pre-order, pick up at the campus stall',
                            style: TextStyle(color: ink)),
                        const SizedBox(height: 2),
                        const Text('Status: Pending (after you place the order)',
                            style: TextStyle(color: ink)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text('Items',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ink)),
                  const SizedBox(height: 8),

                  // One row per item
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          for (int i = 0; i < items.length; i++)
                            _itemRow(items[i], showDivider: i != items.length - 1),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Totals
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _totalRow('Total items', '${CartService.totalQuantity}'),
                          const SizedBox(height: 8),
                          _totalRow('Total price',
                              '₱${CartService.totalPrice.toStringAsFixed(2)}',
                              big: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 8,
                      offset: Offset(0, -2)),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: AppButton(
                    text: 'Proceed to Checkout',
                    onPressed: () => _proceedToCheckout(context),
                  ),
                ),
              ),
            ),
    );
  }

  // One line: "2 x Chicken Adobo Rice ......... ₱150.00"
  Widget _itemRow(CartItem item, {required bool showDivider}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${item.quantity} x ',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: persimmon)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, color: ink)),
                    Text('₱${item.price.toStringAsFixed(2)} each',
                        style: const TextStyle(color: grey, fontSize: 12)),
                  ],
                ),
              ),
              Text('₱${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: ink)),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }

  Widget _totalRow(String label, String value, {bool big = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: big ? 18 : 15,
                fontWeight: big ? FontWeight.w800 : FontWeight.w500,
                color: ink)),
        Text(value,
            style: TextStyle(
                fontSize: big ? 22 : 15,
                fontWeight: FontWeight.w800,
                color: big ? persimmon : ink)),
      ],
    );
  }
}
