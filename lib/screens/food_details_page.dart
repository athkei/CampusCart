import 'package:flutter/material.dart';
import '../common.dart';
import '../models/food_item.dart';
import '../services/cart_service.dart';
import '../widgets/food_image.dart';

/// Food Details: shows one food item, lets the student pick a quantity.
class FoodDetailsPage extends StatefulWidget {
  final FoodItem item;
  const FoodDetailsPage({super.key, required this.item});

  @override
  State<FoodDetailsPage> createState() => _FoodDetailsPageState();
}

class _FoodDetailsPageState extends State<FoodDetailsPage> {
  int quantity = 1;

  // Adds the food and the chosen quantity to the cart, then goes back
  // to the menu. The cart icon there shows the new item count.
  void _addToCart() {
    int added = CartService.addItem(widget.item, quantity);
    final name = widget.item.name;
    final max = CartService.maxQty;

    if (added == 0) {
      showMsg(context, 'Your cart already has the maximum of $max $name.');
    } else if (added < quantity) {
      showMsg(context, 'Only $added x $name added. Maximum is $max per item.');
    } else {
      showMsg(context, '$added x $name added to cart.');
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final total = item.price * quantity;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: const IconThemeData(color: ink),
        title: const Text('Food Details',
            style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Food image
          Hero(
            tag: 'food-${item.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FoodImage(
                url: item.imageUrl,
                width: double.infinity,
                height: 220,
                iconSize: 64,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name and price
          Text(item.name,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 4),
          Text('₱${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: persimmon)),
          const SizedBox(height: 8),

          // Category
          Text('Category: ${item.category}',
              style: const TextStyle(color: grey)),
          const SizedBox(height: 16),

          // Description
          const Text('Description',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
          const SizedBox(height: 4),
          Text(item.description, style: const TextStyle(color: grey)),
          const SizedBox(height: 24),

          // Quantity: - 1 +
          Row(
            children: [
              const Text('Quantity',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: blue),
                onPressed: () {
                  if (quantity > 1) setState(() => quantity--);
                },
              ),
              Text('$quantity',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: blue),
                onPressed: () => setState(() => quantity++),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total + button
          Text('Total: ₱${total.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 12),
          AppButton(text: 'Add to Cart', onPressed: _addToCart),
        ],
      ),
    );
  }
}