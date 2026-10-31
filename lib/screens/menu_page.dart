import 'package:flutter/material.dart';
import '../common.dart';
import '../models/food_item.dart';
import '../services/menu_seeder.dart';
import '../services/menu_service.dart';
import '../widgets/food_image.dart';
import 'food_details_page.dart';
import 'home_page.dart';

/// Food Menu: shows every item from Firestore, with category filter chips.
/// Tap an item to open its details.
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Created once. If this were inside build(), the Firestore stream would
  // restart every time the filter changes.
  late final Stream<List<FoodItem>> _menuStream = MenuService().menuStream();

  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text('Food Menu',
            style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
        actions: [
          // TEMPORARY: uploads sample menu items to Firestore (remove later)
          IconButton(
            icon: const Icon(Icons.cloud_upload, color: persimmon),
            tooltip: 'Upload sample menu',
            onPressed: () async {
              try {
                final n = await MenuSeeder().seed();
                if (context.mounted) {
                  showMsg(context,
                      n == 0 ? 'Menu already has items.' : 'Added $n items.');
                }
              } catch (e) {
                if (context.mounted) showMsg(context, 'Upload failed: $e');
              }
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
            return const Center(
              child: Text('Could not load menu.', style: TextStyle(color: red)),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: blue));
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('No food items yet.'));
          }

          // Build the chip list from whatever categories exist in Firestore.
          final categories = ['All'] +
              (items
                  .map((i) => i.category)
                  .where((c) => c.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort());
          final selected =
              categories.contains(_selectedCategory) ? _selectedCategory : 'All';
          final shown = selected == 'All'
              ? items
              : items.where((i) => i.category == selected).toList();

          return Column(
            children: [
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final c = categories[i];
                    final isSelected = c == selected;
                    return ChoiceChip(
                      label: Text(c),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: blue,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: skyBlue),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : ink,
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = c),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  itemCount: shown.length,
                  itemBuilder: (context, i) => FoodTile(item: shown[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// One menu card: image, name, short description, category, price.
/// Tapping it opens the food details screen.
class FoodTile extends StatelessWidget {
  final FoodItem item;
  const FoodTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FoodDetailsPage(item: item)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'food-${item.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FoodImage(url: item.imageUrl, width: 88, height: 88),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 88,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: grey, fontSize: 13),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (item.category.isNotEmpty)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: blushPink,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: persimmon),
                                ),
                              ),
                            ),
                          const Spacer(),
                          Text(
                            '₱${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: persimmon,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
