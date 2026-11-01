import 'package:flutter/material.dart';
import '../common.dart';
import '../models/food_item.dart';
import '../services/cart_service.dart';
import '../services/menu_service.dart';
import '../widgets/food_image.dart';
import 'cart_page.dart';
import 'food_details_page.dart';
import 'home_page.dart';

/// Food Menu: list of food from Firestore + category filter.
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Created once so the stream doesn't restart when we filter.
  final Stream<List<FoodItem>> _menuStream = MenuService().menuStream();

  // Which category chip is selected right now.
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text('Food Menu',
            style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
        actions: [
          // Cart icon with a badge showing how many items are in the cart
          ValueListenableBuilder<int>(
            valueListenable: CartService.itemCount,
            builder: (context, count, child) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.shopping_cart, color: blue),
                ),
                tooltip: 'My cart',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                ),
              );
            },
          ),
          // Opens the profile screen (photo + sign out)
          IconButton(
            icon: const Icon(Icons.person, color: blue),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<FoodItem>>(
        stream: _menuStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load menu.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: blue));
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('No food items yet.'));
          }

          // 1. Collect the categories (All + every category found).
          final categories = ['All'];
          for (final item in items) {
            if (item.category.isNotEmpty && !categories.contains(item.category)) {
              categories.add(item.category);
            }
          }

          // 2. Keep only the items of the selected category.
          final shownItems = _selectedCategory == 'All'
              ? items
              : items.where((i) => i.category == _selectedCategory).toList();

          return Column(
            children: [
              // Category chips
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(10),
                  children: [
                    for (final category in categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          showCheckmark: false,
                          selectedColor: blue,
                          labelStyle: TextStyle(
                            color: _selectedCategory == category
                                ? Colors.white
                                : ink,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedCategory = category);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              // Food list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: shownItems.length,
                  itemBuilder: (context, index) =>
                      FoodTile(item: shownItems[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// One food row. Tap it to open the details screen.
class FoodTile extends StatelessWidget {
  final FoodItem item;
  const FoodTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FoodDetailsPage(item: item)),
        ),
        leading: Hero(
          tag: 'food-${item.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: FoodImage(url: item.imageUrl, width: 56, height: 56),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w700, color: ink),
        ),
        subtitle: Text(
          '${item.category}\n${item.description}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: Text(
          '₱${item.price.toStringAsFixed(2)}',
          style: const TextStyle(
              fontWeight: FontWeight.w800, color: persimmon, fontSize: 16),
        ),
      ),
    );
  }
}