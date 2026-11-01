import 'package:flutter/material.dart';
import '../common.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../widgets/food_image.dart';
import 'order_summary_page.dart';

/// Cart screen: the student can change quantities, remove items,
/// see the running total, and continue to the Order Summary.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Ask first, then empty the whole cart
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
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: red),
              tooltip: 'Clear cart',
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: items.isEmpty ? _emptyCart() : _cartList(items),
      bottomNavigationBar: items.isEmpty ? null : _bottomBar(),
    );
  }

  // Shown when there is nothing in the cart
  Widget _emptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 80, color: skyBlue),
            const SizedBox(height: 16),
            const Text('Your cart is empty',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
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
    );
  }

  // The list of cart items
  Widget _cartList(List<CartItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, i) => _cartTile(items[i]),
    );
  }

  // One cart item card
  Widget _cartTile(CartItem item) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FoodImage(url: item.imageUrl, width: 72, height: 72),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16, color: ink),
                  ),
                  const SizedBox(height: 2),
                  Text('₱${item.price.toStringAsFixed(2)} each',
                      style: const TextStyle(color: grey, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        visualDensity: VisualDensity.compact,
                        onPressed: item.quantity > 1
                            ? () => setState(() {
                                  CartService.decreaseQuantity(item);
                                })
                            : null,
                        icon: const Icon(Icons.remove, size: 18),
                      ),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: ink),
                        ),
                      ),
                      IconButton.filledTonal(
                        visualDensity: VisualDensity.compact,
                        onPressed: item.quantity < CartService.maxQty
                            ? () => setState(() {
                                  CartService.increaseQuantity(item);
                                })
                            : null,
                        icon: const Icon(Icons.add, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: red),
                  tooltip: 'Remove',
                  onPressed: () {
                    setState(() {
                      CartService.removeItem(item);
                    });
                    showMsg(context, '${item.name} removed from cart.');
                  },
                ),
                Text(
                  '₱${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: persimmon),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Bottom bar: total price + button to the Order Summary
  Widget _bottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total (${CartService.totalQuantity} items)',
                      style: const TextStyle(color: grey, fontSize: 13)),
                  Text(
                    '₱${CartService.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800, color: ink),
                  ),
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
                    // Refresh when coming back (the cart may have changed)
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
