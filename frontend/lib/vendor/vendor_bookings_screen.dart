import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'vendor_api_service.dart';

class VendorBookingsScreen extends StatefulWidget {
  const VendorBookingsScreen({super.key});

  @override
  State<VendorBookingsScreen> createState() => _VendorBookingsScreenState();
}

class _VendorBookingsScreenState extends State<VendorBookingsScreen> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final bookings = await VendorApiService.getBookings();
      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(int bookingId, String newStatus) async {
    try {
      await VendorApiService.updateBookingStatus(bookingId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking marked as $newStatus'), backgroundColor: Colors.green),
      );
      _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.blue;
      case 'active': return Colors.green;
      case 'completed': return Colors.purple;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Bookings'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchBookings),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _fetchBookings, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_bookings.isEmpty) return const Center(child: Text('No bookings found for your bikes.'));

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _bookings.length,
      itemBuilder: (ctx, i) {
        final booking = _bookings[i];
        final start = DateTime.parse(booking['start_time']);
        final end = DateTime.parse(booking['end_time']);
        final formatter = DateFormat('dd MMM, h:mm a');
        final status = booking['status'] as String;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking #${booking['booking_id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Chip(
                      label: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: _getStatusColor(status),
                    ),
                  ],
                ),
                const Divider(),
                Text('Bike: ${booking['bike_model']}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Text('User: ${booking['user_name']} (${booking['user_phone']})'),
                const SizedBox(height: 4),
                Text('Duration: ${formatter.format(start)} - ${formatter.format(end)}'),
                const SizedBox(height: 4),
                Text('Total: ₹${booking['total_price']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                
                // Action Buttons based on status
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (status == 'pending') ...[
                      OutlinedButton(
                        onPressed: () => _updateStatus(booking['booking_id'], 'cancelled'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _updateStatus(booking['booking_id'], 'approved'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Approve'),
                      ),
                    ],
                    if (status == 'approved')
                      ElevatedButton(
                        onPressed: () => _updateStatus(booking['booking_id'], 'active'),
                        child: const Text('Mark Active (Handed Over)'),
                      ),
                    if (status == 'active')
                      ElevatedButton(
                        onPressed: () => _updateStatus(booking['booking_id'], 'completed'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                        child: const Text('Mark Returned (Complete)'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
