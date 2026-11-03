import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference<Map<String, dynamic>> _orders =
      _db.collection('orders');

  static Future<void> placeOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required double totalPrice,
    String status = 'Pending',
  }) async {
    if (userId.trim().isEmpty) {
      throw StateError('A logged-in user is required to place an order.');
    }
    if (items.isEmpty) {
      throw StateError('Cart is empty. Add at least one food item before placing an order.');
    }

    await _orders.add({
      'uid': userId,
      'userId': userId,
      'items': items,
      'totalPrice': totalPrice,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'pickupType': 'Pre-order, pick up at the campus stall',
    });
  }
}
