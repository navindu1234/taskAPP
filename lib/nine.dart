import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SellerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> sellerDetails;

  const SellerDetailsScreen({super.key, required this.sellerDetails});

  @override
  _SellerDetailsScreenState createState() => _SellerDetailsScreenState();
}

class _SellerDetailsScreenState extends State<SellerDetailsScreen> {
  String _orderStatus = 'pending'; // Default status

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': status});
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: $e'),
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
        title: const Text('Seller Details',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seller Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildSellerDetailsCard(),
              const SizedBox(height: 24),
              const Text(
                'Order Status',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildOrderStatusToggle(),
              const SizedBox(height: 16),
              Text(
                '$_orderStatus Orders'.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildOrdersList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellerDetailsCard() {
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
              _buildInfoRow(Icons.person_outline, 'Full Name',
                  widget.sellerDetails['name'] ?? 'Unknown'),
              _buildInfoRow(Icons.location_on, 'Address',
                  widget.sellerDetails['address'] ?? 'No address'),
              _buildInfoRow(Icons.phone, 'Primary Telephone',
                  widget.sellerDetails['telephone'] ?? 'No telephone'),
              _buildInfoRow(Icons.phone_android, 'Secondary Telephone',
                  widget.sellerDetails['secondaryTelephone'] ?? 'Not provided'),
              _buildInfoRow(Icons.description, 'Service Description',
                  widget.sellerDetails['serviceDescription'] ?? 'No description'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
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
          .where('sellerName', isEqualTo: widget.sellerDetails['name'])
          .where('status', isEqualTo: _orderStatus)
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
          return const Center(
            child: Text(
              "Error loading orders",
              style: TextStyle(color: Colors.white),
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
        return ListView.separated(
          itemCount: orders.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.white.withOpacity(0.1),
            height: 1,
          ),
          itemBuilder: (context, index) {
            var order = orders[index].data() as Map<String, dynamic>;
            return Container(
              decoration: BoxDecoration(
                color: Colors.blue[700]!.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[900],
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  "Order #${order['orderId']?.toString().substring(0, 6) ?? 'N/A'}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  "${order['sellerServiceDescription'] ?? 'Service'}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                trailing: _orderStatus == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check_circle,
                                color: Colors.green[300]),
                            onPressed: () =>
                                _updateOrderStatus(orders[index].id, 'accepted'),
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red[300]),
                            onPressed: () =>
                                _updateOrderStatus(orders[index].id, 'rejected'),
                          ),
                        ],
                      )
                    : Icon(
                        _orderStatus == 'accepted'
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _orderStatus == 'accepted'
                            ? Colors.green[300]
                            : Colors.red[300],
                      ),
              ),
            );
          },
        );
      },
    );
  }
}