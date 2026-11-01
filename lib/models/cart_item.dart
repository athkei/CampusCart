/// One line in the cart: a food item plus how many the student wants.
class CartItem {
  final String foodId;
  final String name;
  final String imageUrl;
  final double price; // price of ONE piece
  int quantity;

  CartItem({
    required this.foodId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  /// price x quantity
  double get subtotal => price * quantity;

  /// Plain map so the order can be saved in Firestore (used by Checkout).
  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}
