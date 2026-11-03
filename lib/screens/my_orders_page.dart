import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../common.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';

/// Live order history for the signed-in student.
/// The status selector is a UI-only demo; it does not write to Firestore.
class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  static const _statuses = <String>[
    'Pending',
    'Preparing',
    'Ready for Pickup',
    'Completed',
  ];

  // Temporary preview state used only by the interface. It is intentionally
  // not persisted, since this project needs the status-update UI, not backend
  // status-management functionality.
  final Map<String, String> _previewStatuses = {};

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Preparing':
        return blue;
      case 'Ready for Pickup':
        return Colors.green;
      case 'Completed':
        return grey;
      default:
        return persimmon;
    }
  }

  String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate().toLocal();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final hour = (date.hour % 12 == 0 ? 12 : date.hour % 12)
          .toString()
          .padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$month/$day/${date.year} at $hour:$minute $period';
    }
    return 'Order time unavailable';
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: const IconThemeData(color: ink),
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w800, color: ink),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Sign in to view your orders.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: OrderService.ordersForUser(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Could not load your orders. Please try again.'),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: blue),
                  );
                }

                final orders = snapshot.data?.docs ?? [];
                if (orders.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long, size: 64, color: skyBlue),
                          SizedBox(height: 12),
                          Text('No orders yet.'),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final doc = orders[index];
                    final data = doc.data();
                    final storedStatus = data['status'] is String
                        ? data['status'] as String
                        : 'Pending';
                    final storedStatusIndex = _statuses.indexOf(storedStatus);
                    final status = _previewStatuses[doc.id] ??
                        (storedStatusIndex < 0 ? 'Pending' : storedStatus);
                    final rawItems = data['items'];
                    final items = rawItems is List ? rawItems : const [];
                    final total = data['totalPrice'];
                    final totalPrice = total is num ? total.toDouble() : 0.0;
                    final activeIndex = _statuses.indexOf(status);

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Campus pickup order',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: ink,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  backgroundColor: _statusColor(status),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            Text(
                              _formatTimestamp(data['timestamp']),
                              style: const TextStyle(color: grey),
                            ),
                            const SizedBox(height: 10),
                            for (final rawItem in items)
                              if (rawItem is Map)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Text(
                                    '${rawItem['quantity'] ?? 0} x ${rawItem['name'] ?? 'Food item'}',
                                    style: const TextStyle(color: ink),
                                  ),
                                ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Order ${doc.id.substring(0, 6)}'),
                                Text(
                                  '₱${totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: persimmon,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: status,
                              decoration: const InputDecoration(
                                labelText: 'Update status (demo only)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: _statuses
                                  .map((value) => DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _previewStatuses[doc.id] = value);
                              },
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Demo control: this selection changes the screen only; it is not saved to Firestore.',
                              style: TextStyle(fontSize: 12, color: grey),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                for (var i = 0; i < _statuses.length; i++) ...[
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Icon(
                                          i <= activeIndex
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          size: 18,
                                          color: i <= activeIndex
                                              ? _statusColor(status)
                                              : skyBlue,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _statuses[i],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: i <= activeIndex ? ink : grey,
                                            fontWeight: i == activeIndex
                                                ? FontWeight.w800
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (i < _statuses.length - 1)
                                    const SizedBox(width: 2),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
