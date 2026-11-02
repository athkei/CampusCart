import 'package:flutter/material.dart';
import '../common.dart';
import '../services/cart_service.dart';
import '../widgets/food_image.dart';
import 'order_summary_page.dart';

/// My Cart: change quantities, remove items, see the total.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Ask first, then empty the whole cart.
  void _confirmClear() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('All items will be removed from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                CartService.clear();
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear', style: TextStyle(color: red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = CartService.items;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: const IconThemeData(color: ink),
        title: const Text('My Cart',
            style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
        actions: [
          // Clear button only shows when the cart has items
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: red),
              onPressed: _confirmClear,
            ),
        ],
      ),

      // If the cart is empty show a message, if not show the list
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_outlined,
                        size: 80, color: skyBlue),
                    const SizedBox(height: 16),
                    const Text('Your cart is empty',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: ink)),
                    const SizedBox(height: 6),
                    const Text('Add some food from the menu first.',
                        style: TextStyle(color: grey)),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Browse Menu',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // One card for every item in the cart
                for (final item in items)
                  Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          // Food image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FoodImage(
                                url: item.imageUrl, width: 72, height: 72),
                          ),
                          const SizedBox(width: 12),

                          // Name, price, quantity buttons
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: ink)),
                                Text('₱${item.price.toStringAsFixed(2)} each',
                                    style: const TextStyle(color: grey)),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          color: blue),
                                      onPressed: () {
                                        setState(() {
                                          CartService.decreaseQuantity(item);
                                        });
                                      },
                                    ),
                                    Text('${item.quantity}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: ink)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle,
                                          color: blue),
                                      onPressed: () {
                                        setState(() {
                                          CartService.increaseQuantity(item);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Remove button and subtotal
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close, color: red),
                                onPressed: () {
                                  setState(() {
                                    CartService.removeItem(item);
                                  });
                                  showMsg(context,
                                      '${item.name} removed from cart.');
                                },
                              ),
                              Text('₱${item.subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
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

      // Bottom bar: total + Review Order (hidden when the cart is empty)
      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total (${CartService.totalQuantity} items)',
                              style: const TextStyle(color: grey)),
                          Text(
                              '₱${CartService.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: ink)),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: AppButton(
                          text: 'Review Order',
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const OrderSummaryPage()),
                            );
                            // Refresh when coming back
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
