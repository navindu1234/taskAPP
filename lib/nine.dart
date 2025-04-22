import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SellerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> sellerDetails;

  const SellerDetailsScreen({super.key, required this.sellerDetails});

  @override
  _SellerDetailsScreenState createState() => _SellerDetailsScreenState();
}

class _SellerDetailsScreenState extends State<SellerDetailsScreen> {
  String _orderStatus = 'pending'; // Default status
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
            'status': status,
            'lastUpdated': FieldValue.serverTimestamp(),
            'notificationSeen': false,
          });

      // Create a notification for the buyer
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();
      final orderData = orderDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance.collection('notifications').add({
        'recipientId': orderData['userId'],
        'senderId': widget.sellerDetails['uid'],
        'type': 'order_update',
        'orderId': orderId,
        'message': 'Your order status has been updated to $status',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $status'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.blue[800],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: ${e.toString()}'),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[900]!,
              Colors.blue[800]!,
              Colors.blue[700]!,
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSellerInfoCard(),
                  const SizedBox(height: 16),
                  _buildSearchField(),
                  const SizedBox(height: 16),
                  _buildOrderStatusToggle(),
                ],
              ),
            ),
            Expanded(
              child: _buildOrdersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[800],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[900],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  widget.sellerDetails['name'] ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  widget.sellerDetails['serviceDescription'] ?? 'No service description',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
              const Divider(color: Colors.white54, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.pending_actions, 'Pending', _orderStatus == 'pending'),
                  _buildStatItem(Icons.check_circle, 'Accepted', _orderStatus == 'accepted'),
                  _buildStatItem(Icons.cancel, 'Rejected', _orderStatus == 'rejected'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, bool isSelected) {
    return Column(
      children: [
        Icon(icon, color: isSelected ? Colors.white : Colors.white.withOpacity(0.6)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        hintText: 'Search orders...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
    );
  }

  Widget _buildOrderStatusToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ToggleButtons(
        isSelected: [
          _orderStatus == 'pending',
          _orderStatus == 'accepted',
          _orderStatus == 'rejected'
        ],
        onPressed: (int index) {
          setState(() {
            _orderStatus = ['pending', 'accepted', 'rejected'][index];
          });
        },
        borderRadius: BorderRadius.circular(8),
        constraints: const BoxConstraints(
          minWidth: 100,
          minHeight: 40,
        ),
        selectedColor: Colors.blue[900],
        fillColor: Colors.white,
        color: Colors.white.withOpacity(0.8),
        selectedBorderColor: Colors.transparent,
        borderColor: Colors.transparent,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Pending',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _orderStatus == 'pending'
                    ? Colors.blue[900]
                    : Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Accepted',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _orderStatus == 'accepted'
                    ? Colors.blue[900]
                    : Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Rejected',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _orderStatus == 'rejected'
                    ? Colors.blue[900]
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: widget.sellerDetails['uid'])
          .where('status', isEqualTo: _orderStatus)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading orders",
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No $_orderStatus orders",
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          );
        }

        var orders = snapshot.data!.docs;
        
        // Filter orders based on search query
        final filteredOrders = _searchQuery.isEmpty
            ? orders
            : orders.where((doc) {
                final order = doc.data() as Map<String, dynamic>;
                final orderId = order['orderId']?.toString().toLowerCase() ?? '';
                final username = order['username']?.toString().toLowerCase() ?? '';
                final description = order['description']?.toString().toLowerCase() ?? '';
                return orderId.contains(_searchQuery) ||
                    username.contains(_searchQuery) ||
                    description.contains(_searchQuery);
              }).toList();

        if (filteredOrders.isEmpty) {
          return Center(
            child: Text(
              "No orders match your search",
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            var orderDoc = filteredOrders[index];
            var order = orderDoc.data() as Map<String, dynamic>;
            return _buildOrderCard(order, orderDoc.id);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, String orderId) {
    final timestamp = order['timestamp'] as Timestamp?;
    final dateTime = timestamp?.toDate();
    final formattedDate = dateTime != null 
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime)
        : 'Date not available';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOrderDetails(order, orderId),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${order['orderId']?.toString().substring(0, 8) ?? 'N/A'}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                order['description'] ?? 'No description',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    order['username'] ?? 'Unknown user',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const Spacer(),
                  const Icon(Icons.phone, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    order['userPhone'] ?? 'No phone',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_orderStatus == 'pending')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _updateOrderStatus(orderId, 'accepted'),
                      child: const Text('Accept', style: TextStyle(color: Colors.green)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _updateOrderStatus(orderId, 'rejected'),
                      child: const Text('Reject', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  void _showOrderDetails(Map<String, dynamic> order, String orderId) {
    final timestamp = order['timestamp'] as Timestamp?;
    final dateTime = timestamp?.toDate();
    final formattedDate = dateTime != null 
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime)
        : 'Date not available';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            AppBar(
              title: Text('Order Details #${order['orderId']?.toString().substring(0, 8) ?? ''}'),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('Status', order['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                        _getStatusColor(order['status'])),
                    _buildDetailItem('Order Date', formattedDate),
                    _buildDetailItem('Customer', order['username'] ?? 'Unknown'),
                    _buildDetailItem('Customer Phone', order['userPhone'] ?? 'Not provided'),
                    const Divider(height: 24),
                    _buildDetailItem('Service', widget.sellerDetails['serviceDescription'] ?? 'No service description'),
                    _buildDetailItem('Quantity', order['quantity']?.toString() ?? 'Not specified'),
                    _buildDetailItem('Description', order['description'] ?? 'No description'),
                    _buildDetailItem('Place', order['place'] ?? 'Not specified'),
                    _buildDetailItem('Time', order['time'] ?? 'Not specified'),
                    const SizedBox(height: 24),
                    if (_orderStatus == 'pending')
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                _updateOrderStatus(orderId, 'accepted');
                                Navigator.pop(context);
                              },
                              child: const Text('Accept Order'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                _updateOrderStatus(orderId, 'rejected');
                                Navigator.pop(context);
                              },
                              child: const Text('Reject Order'),
                            ),
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
    );
  }

  Widget _buildDetailItem(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
} 