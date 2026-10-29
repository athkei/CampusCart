import 'package:cloud_firestore/cloud_firestore.dart';

/// One food item from the Firestore "menu" collection.
class FoodItem {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final double price;
  final String category;

  FoodItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.category,
  });

  factory FoodItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return FoodItem(
      id: doc.id,
      name: d['name'] ?? '',
      imageUrl: d['imageUrl'] ?? '',
      description: d['description'] ?? '',
      price: (d['price'] ?? 0).toDouble(),
      category: d['category'] ?? '',
    );
  }
}
