import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../common.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage>
    with SingleTickerProviderStateMixin {
  static const List<String> _statuses = [
    'Pending',
    'Preparing',
    'Ready for Pickup',
    'Completed',
  ];

  late final TabController _controller;

  // Demo-only status changes are local to this screen and are not written to Firestore.
  final Map<String, String> _demoStatusOverrides = {};

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _statusFor(Map<String, dynamic> data, String orderId) {
    final override = _demoStatusOverrides[orderId];
    if (override != null) return override;

    final rawStatus = data['status'];
    if (rawStatus is! String || rawStatus.trim().isEmpty) return 'Pending';

    // Accept both title-case statuses in this app and lowercase values from
    // the source CampusCart implementation.
    final normalized = rawStatus.trim().toLowerCase();
    for (final status in _statuses) {
      if (status.toLowerCase() == normalized) return status;
    }
    return rawStatus;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return blue;
      case 'ready for pickup':
        return Colors.green;
      case 'completed':
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

  double _totalPrice(Map<String, dynamic> data) {
    final total = data['totalPrice'] ?? data['total'] ?? data['subtotal'];
    return total is num ? total.toDouble() : 0.0;
  }

  Widget _emptyState(String status) {
    final message = switch (status) {
      'Pending' => "You don't have any pending orders.",
      'Preparing' => "You don't have any orders being prepared.",
      'Ready for Pickup' => "You don't have any orders ready for pickup.",
      _ => "You don't have any completed orders yet.",
    };
    final hint = switch (status) {
      'Pending' => 'Orders you place will appear here.',
      'Preparing' => 'Accepted orders appear here while the stall prepares them.',
      'Ready for Pickup' => 'Orders ready to collect will appear here.',
      _ => 'Your completed orders will be kept here.',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: skyBlue),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(hint, textAlign: TextAlign.center, style: const TextStyle(color: grey)),
          ],
        ),
      ),
    );
  }

  Widget _ordersForStatus(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orders,
    String status,
  ) {
    final matchingOrders = orders.where((doc) {
      return _statusFor(doc.data(), doc.id).toLowerCase() == status.toLowerCase();
    }).toList();

    if (matchingOrders.isEmpty) return _emptyState(status);

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: matchingOrders.length,
      itemBuilder: (context, index) {
        final doc = matchingOrders[index];
        final data = doc.data();
        final currentStatus = _statusFor(data, doc.id);
        final rawItems = data['items'];
        final items = rawItems is List ? rawItems : const [];
        final timestamp = data['timestamp'] ?? data['createdAt'];

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        data['orderCode'] is String
                            ? 'Order #${data['orderCode']}'
                            : 'Campus pickup order',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: ink,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        currentStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      backgroundColor: _statusColor(currentStatus),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                Text(_formatTimestamp(timestamp), style: const TextStyle(color: grey)),
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
                    Text('Order ${doc.id.substring(0, doc.id.length < 6 ? doc.id.length : 6)}'),
                    Text(
                      '₱${_totalPrice(data).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: persimmon),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _statuses.contains(currentStatus) ? currentStatus : 'Pending',
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
                    setState(() => _demoStatusOverrides[doc.id] = value);
                  },
                ),
                const SizedBox(height: 6),
                const Text(
                  'Demo mode: this selector only changes the screen display.',
                  style: TextStyle(fontSize: 12, color: grey),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          indicatorColor: blue,
          labelColor: blue,
          unselectedLabelColor: grey,
          tabs: _statuses.map((status) => Tab(text: status)).toList(),
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
                  return const Center(child: CircularProgressIndicator(color: blue));
                }

                final orders = snapshot.data?.docs ?? [];
                return TabBarView(
                  controller: _controller,
                  children: _statuses
                      .map((status) => _ordersForStatus(orders, status))
                      .toList(),
                );
              },
            ),
    );
  }
}
