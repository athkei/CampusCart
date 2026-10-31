import 'package:flutter/material.dart';
import '../common.dart';
import '../models/food_item.dart';
import '../widgets/food_image.dart';

class FoodDetailsPage extends StatefulWidget {
  final FoodItem item;
  const FoodDetailsPage({super.key, required this.item});

  @override
  State<FoodDetailsPage> createState() => _FoodDetailsPageState();
}

class _FoodDetailsPageState extends State<FoodDetailsPage> {
  static const int _maxQty = 20;
  int _quantity = 1;

  FoodItem get item => widget.item;
  double get _total => item.price * _quantity;

  // ---------------------------------------------------------------------
  // TODO (cart teammate): this is the only place that needs to change.
  // Use `item` (the food) and `_quantity` (how many) to add the order line
  // to the cart, then show a confirmation / go to the cart screen.
  // Right now the button is a placeholder and does NOT add anything.
  // ---------------------------------------------------------------------
  void _addToCart() {
    showMsg(context, 'Add to Cart is not connected yet.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: const IconThemeData(color: ink),
        title: const Text('Food Details',
            style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'food-${item.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FoodImage(
                        url: item.imageUrl,
                        width: double.infinity,
                        height: 240,
                        iconSize: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: ink),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '₱${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: persimmon),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (item.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: blushPink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: persimmon),
                      ),
                    ),
                  const SizedBox(height: 18),
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ink)),
                  const SizedBox(height: 6),
                  Text(
                    item.description.isEmpty
                        ? 'No description available.'
                        : item.description,
                    style: const TextStyle(
                        fontSize: 15, height: 1.4, color: grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Quantity',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: ink)),
                      ),
                      IconButton.filledTonal(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '$_quantity',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ink),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: _quantity < _maxQty
                            ? () => setState(() => _quantity++)
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bottom bar: running total + Add to Cart
          Container(
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
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total',
                            style: TextStyle(color: grey, fontSize: 13)),
                        Text(
                          '₱${_total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ink),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: AppButton(
                        text: 'Add to Cart',
                        onPressed: _addToCart,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
