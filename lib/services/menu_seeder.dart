import 'package:cloud_firestore/cloud_firestore.dart';

/// ONE-TIME helper: uploads sample food items to the Firestore "menu"
/// collection. Remove this file (and the upload button in menu_page.dart)
/// after the menu is in Firestore.
class MenuSeeder {
  static const List<Map<String, dynamic>> _items = [
    {
      'name': 'Chicken Adobo Rice',
      'description': 'Tender chicken in soy-vinegar sauce with steamed rice',
      'price': 75,
      'category': 'Rice meals',
      'imageUrl': '',
    },
    {
      'name': 'Pork Sisig Rice',
      'description': 'Sizzling chopped pork with onions, served with rice',
      'price': 85,
      'category': 'Rice meals',
      'imageUrl': '',
    },
    {
      'name': 'Pancit Canton',
      'description': 'Stir-fried noodles with vegetables and egg',
      'price': 55,
      'category': 'Noodles',
      'imageUrl': '',
    },
    {
      'name': 'Fish Fillet Sandwich',
      'description': 'Crispy fish fillet with tartar sauce on a soft bun',
      'price': 45,
      'category': 'Snacks',
      'imageUrl': '',
    },
    {
      'name': 'French Fries',
      'description': 'Crispy golden fries with your choice of flavor',
      'price': 35,
      'category': 'Snacks',
      'imageUrl': '',
    },
    {
      'name': 'Iced Milk Tea',
      'description': 'Classic milk tea with pearls, 16 oz',
      'price': 60,
      'category': 'Drinks',
      'imageUrl': '',
    },
    {
      'name': 'Bottled Water',
      'description': 'Purified drinking water, 500 ml',
      'price': 20,
      'category': 'Drinks',
      'imageUrl': '',
    },
  ];

  /// Writes all items in one batch. Skips if the menu already has items.
  /// Returns how many items were added.
  Future<int> seed() async {
    final menu = FirebaseFirestore.instance.collection('menu');
    final existing = await menu.limit(1).get();
    if (existing.docs.isNotEmpty) return 0;

    final batch = FirebaseFirestore.instance.batch();
    for (final item in _items) {
      batch.set(menu.doc(), item);
    }
    await batch.commit();
    return _items.length;
  }
}
