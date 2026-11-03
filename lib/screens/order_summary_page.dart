import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../common.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  bool _isPlacingOrder = false;

  Future<void> _proceedToCheckout() async {
    final user = AuthService().currentUser;
    if (user == null) {
      if (!mounted) return;
      showMsg(context, 'Please sign in before placing an order.');
      return;
    }

    if (CartService.items.isEmpty) {
      if (!mounted) return;
      showMsg(context, 'Your cart is empty.');
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final orderItems = CartService.toOrderItems();

      await OrderService.placeOrder(
        userId: user.uid,
        items: orderItems,
        totalPrice: CartService.totalPrice,
      );

      if (!mounted) return;

      CartService.clear();

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrderPlacedScreen()),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      showMsg(context, 'Could not place order: ${e.message ?? e.code}');
    } on StateError catch (e) {
      if (!mounted) return;
      showMsg(context, e.message);
    } catch (e) {
      if (!mounted) return;
      showMsg(context, 'Something went wrong while placing your order.');
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = CartService.items;
    final email = AuthService().currentUser?.email ?? 'Unknown student';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: const IconThemeData(color: ink),
        title: const Text(
          'Order Summary',
          style: TextStyle(fontWeight: FontWeight.w800, color: ink),
        ),
      ),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: blushPink,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Ordered by: $email'),
                      const Text('Type: Pre-order, pick up at the campus stall'),
                      const Text('Status: Pending'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        for (final item in items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.quantity} x ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: persimmon,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: ink,
                                        ),
                                      ),
                                      Text(
                                        '₱${item.price.toStringAsFixed(2)} each',
                                        style: const TextStyle(color: grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₱${item.subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total items',
                              style: TextStyle(fontSize: 15, color: ink),
                            ),
                            Text(
                              '${CartService.totalQuantity}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: ink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total price',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: ink,
                              ),
                            ),
                            Text(
                              '₱${CartService.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: persimmon,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isPlacingOrder
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : AppButton(
                          text: 'Place Order',
                          onPressed: _proceedToCheckout,
                        ),
                ),
              ),
            ),
    );
  }
}

class OrderPlacedScreen extends StatelessWidget {
  const OrderPlacedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 90,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Order placed successfully!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your order is now pending and will be prepared soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: grey),
                ),
                const SizedBox(height: 26),
                AppButton(
                  text: 'Back to Menu',
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
