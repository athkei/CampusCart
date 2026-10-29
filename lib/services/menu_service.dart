import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';

/// Reads the food menu from Firestore (collection: "menu").
class MenuService {
  final _menu = FirebaseFirestore.instance.collection('menu');

  /// Live list of food items, sorted by name.
  Stream<List<FoodItem>> menuStream() {
    return _menu.orderBy('name').snapshots().map(
          (snap) => snap.docs.map((doc) => FoodItem.fromDoc(doc)).toList(),
        );
  }
}
