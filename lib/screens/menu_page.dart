import 'package:flutter/material.dart';
import '../common.dart';
import '../models/food_item.dart';
import '../services/menu_seeder.dart';
import '../services/menu_service.dart';
import 'home_page.dart';

/// Food Menu: shows every item from Firestore using ListTile.
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

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
        stream: MenuService().menuStream(),
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
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, i) => FoodTile(item: items[i]),
          );
        },
      ),
    );
  }
}

/// One menu row: image, name, description + category, price.
class FoodTile extends StatelessWidget {
  final FoodItem item;
  const FoodTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            item.imageUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 64,
              height: 64,
              color: skyBlue,
              child: const Icon(Icons.fastfood, color: oceanBlue),
            ),
          ),
        ),
        title: Text(item.name,
            style: const TextStyle(fontWeight: FontWeight.w700, color: ink)),
        subtitle: Text(
          '${item.description}\n${item.category}',
          maxLines: 3,
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
