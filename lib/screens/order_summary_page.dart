import 'package:flutter/material.dart';
import '../common.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';

/// Order Summary: review the items, quantity, price and total before ordering.
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
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Order details
                Container(
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
                      Text('Ordered by: $email'),
                      const Text('Type: Pre-order, pick up at the campus stall'),
                      const Text('Status: Pending (after you place the order)'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Items
                const Text('Items',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ink)),
                const SizedBox(height: 8),
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // One row for every item: 2 x Adobo ........ ₱150.00
                        for (final item in items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item.quantity} x ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: persimmon)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: ink)),
                                      Text(
                                          '₱${item.price.toStringAsFixed(2)} each',
                                          style: const TextStyle(color: grey)),
                                    ],
                                  ),
                                ),
                                Text('₱${item.subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: ink)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Totals
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total items',
                                style: TextStyle(fontSize: 15, color: ink)),
                            Text('${CartService.totalQuantity}',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: ink)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total price',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: ink)),
                            Text(
                                '₱${CartService.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: persimmon)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

      // Checkout button (hidden when the cart is empty)
      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppButton(
                    text: 'Proceed to Checkout',
                    onPressed: () => _proceedToCheckout(context),
                  ),
                ),
              ),
            ),
    );
  }
}
