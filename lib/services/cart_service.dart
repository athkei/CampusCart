import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../models/cart_item.dart';

/// Keeps the student's cart while the app is open.
/// Everything is static, so any screen can use it like this:
///   CartService.addItem(food, 2);
///   CartService.totalPrice;
class CartService {
  static const int maxQty = 20;

  // The items currently in the cart
  static final List<CartItem> items = [];

  // Number of pieces in the cart. The cart icon on the menu listens to this
  // so the red badge updates by itself.
  static final ValueNotifier<int> itemCount = ValueNotifier<int>(0);

  // Total number of pieces (example: 2 adobo + 1 milk tea = 3)
  static int get totalQuantity {
    int total = 0;
    for (int i = 0; i < items.length; i++) {
      total = total + items[i].quantity;
    }
    return total;
  }

  // Total price of everything in the cart
  static double get totalPrice {
    double total = 0;
    for (int i = 0; i < items.length; i++) {
      total = total + items[i].subtotal;
    }
    return total;
  }

  static bool get isEmpty => items.isEmpty;

  // Add food to the cart. If it is already there, just add to its quantity.
  // Returns how many pieces were REALLY added (0 if the item is already at
  // the maximum), so the screen can show the correct message.
  static int addItem(FoodItem food, int quantity) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].foodId == food.id) {
        int space = maxQty - items[i].quantity;
        int added = quantity;
        if (added > space) added = space;
        items[i].quantity = items[i].quantity + added;
        _updateCount();
        return added;
      }
    }

    // A new item also respects the maximum quantity
    if (quantity > maxQty) quantity = maxQty;

    items.add(CartItem(
      foodId: food.id,
      name: food.name,
      imageUrl: food.imageUrl,
      price: food.price,
      quantity: quantity,
    ));
    _updateCount();
    return quantity;
  }

  static void increaseQuantity(CartItem item) {
    if (item.quantity < maxQty) {
      item.quantity = item.quantity + 1;
      _updateCount();
    }
  }

  static void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity = item.quantity - 1;
      _updateCount();
    }
  }

  static void removeItem(CartItem item) {
    items.remove(item);
    _updateCount();
  }

  // Empty the cart (used after checkout and when logging out)
  static void clear() {
    items.clear();
    _updateCount();
  }

  // The cart items as a list of maps, ready to save inside an order document.
  static List<Map<String, dynamic>> toOrderItems() {
    List<Map<String, dynamic>> list = [];
    for (int i = 0; i < items.length; i++) {
      list.add(items[i].toMap());
    }
    return list;
  }

  static void _updateCount() {
    itemCount.value = totalQuantity;
  }
}
