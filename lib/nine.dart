import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class NineScreen extends StatefulWidget {
  final Map<String, dynamic> sellerDetails;

  const NineScreen({super.key, required this.sellerDetails});

  @override
  _NineScreenState createState() => _NineScreenState();
}

class _NineScreenState extends State<NineScreen> {
  String _orderStatus = 'pending';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final Color _primaryColor = Colors.blue[900]!;
  final Color _secondaryColor = Colors.blue[800]!;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': status,
        'lastUpdated': FieldValue.serverTimestamp(),
        'notificationSeen': false,
      });

      final orderDoc = await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
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
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Dashboard', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: _primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryColor, _secondaryColor, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSellerProfileSection(),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSellerDetailsCard(),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSearchField(),
                    ),
                    const SizedBox(height: 12),
                    _buildOrderStatusToggle(),
                    const SizedBox(height: 12),
                    _buildOrdersList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  image: widget.sellerDetails['profileImage'] != null
                      ? DecorationImage(
                          image: NetworkImage(widget.sellerDetails['profileImage']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.sellerDetails['profileImage'] == null
                    ? Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
              if (widget.sellerDetails['hasCertifications'] == true)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.verified, size: 20, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.sellerDetails['name'] ?? 'No Name',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.sellerDetails['service'] ?? 'No Service',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                (widget.sellerDetails['rating'] ?? 0.0).toStringAsFixed(1),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              Text(
                ' (${widget.sellerDetails['reviewsCount'] ?? 0})',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.work, 'Category:', widget.sellerDetails['category'] ?? 'Not specified'),
            _buildDetailRow(Icons.location_city, 'City:', widget.sellerDetails['city'] ?? 'Not specified'),
            _buildDetailRow(Icons.place, 'Address:', widget.sellerDetails['address'] ?? 'Not specified'),
            _buildDetailRow(Icons.location_on, 'Preferred Location:', widget.sellerDetails['preferredLocation'] ?? 'Not specified'),
            _buildDetailRow(Icons.business_center, 'Work Type:', widget.sellerDetails['workType'] ?? 'Not specified'),
            _buildDetailRow(Icons.school, 'Education:', widget.sellerDetails['education'] ?? 'Not specified'),
            _buildDetailRow(Icons.timeline, 'Experience:', widget.sellerDetails['experience'] ?? 'Not specified'),
            _buildDetailRow(Icons.confirmation_number, 'Unique Code:', widget.sellerDetails['uniqueCode'] ?? 'Not specified'),
            if (widget.sellerDetails['phone'] != null)
              GestureDetector(
                onTap: () => _makePhoneCall(widget.sellerDetails['phone']),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: _primaryColor, size: 24),
                      const SizedBox(width: 16),
                      Text(
                        'Phone: ${widget.sellerDetails['phone']}',
                        style: GoogleFonts.poppins(),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Call Now',
                          style: GoogleFonts.poppins(color: _primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.sellerDetails['hasCertifications'] == true && widget.sellerDetails['certificationImage'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Certifications:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.sellerDetails['certificationImage'],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
      decoration: InputDecoration(
        hintText: 'Search Orders...',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.search, color: _primaryColor),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: _primaryColor),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: _primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildOrderStatusToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ToggleButtons(
          isSelected: [
            _orderStatus == 'pending',
            _orderStatus == 'accepted',
            _orderStatus == 'rejected',
          ],
          onPressed: (index) => setState(() => _orderStatus = ['pending', 'accepted', 'rejected'][index]),
          borderRadius: BorderRadius.circular(30),
          selectedColor: Colors.white,
          fillColor: _primaryColor,
          color: Colors.white,
          selectedBorderColor: Colors.white,
          borderColor: Colors.transparent,
          constraints: const BoxConstraints(minHeight: 40),
          children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Pending', style: GoogleFonts.poppins())),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Accepted', style: GoogleFonts.poppins())),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Rejected', style: GoogleFonts.poppins())),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: widget.sellerDetails['uid'])
          .where('status', isEqualTo: _orderStatus)
          //.orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading orders: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No $_orderStatus orders found',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          );
        }

        final orders = snapshot.data!.docs.where((doc) {
          final order = doc.data() as Map<String, dynamic>;
          return _searchQuery.isEmpty ||
              (order['orderName']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
              (order['username']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
              (order['description']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
              (order['orderId']?.toString().toLowerCase().contains(_searchQuery) ?? false);
        }).toList();

        if (orders.isEmpty) {
          return Center(
            child: Text(
              'No orders match your search',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final orderDoc = orders[index];
            final orderData = orderDoc.data() as Map<String, dynamic>;
            return _buildOrderCard(orderData, orderDoc.id);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, String orderId) {
    final dateTime = (order['timestamp'] as Timestamp?)?.toDate();
    final formattedDate = dateTime != null ? DateFormat('MMM dd, yyyy – hh:mm a').format(dateTime) : 'No Date';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${order['orderId']?.toString().substring(0, 8) ?? 'N/A'}",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Chip(
                  label: Text(
                    (order['status']?.toString().toUpperCase() ?? 'PENDING'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: _getStatusColor(order['status']),
                ),
              ],
            ),
            
            // Order Date
            Text(
              formattedDate,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            
            // Order Name
            if (order['orderName'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order: ${order['orderName']}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            
            // Order Description
            if (order['description'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    order['description'],
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            
            // Customer Info
            Row(
              children: [
                Icon(Icons.person, size: 16, color: _primaryColor),
                const SizedBox(width: 4),
                Text(
                  'Customer: ${order['username'] ?? 'Unknown'}',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Customer Phone
            GestureDetector(
              onTap: order['userPhone'] != null ? () => _makePhoneCall(order['userPhone']) : null,
              child: Row(
                children: [
                  Icon(Icons.phone, size: 16, color: _primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    'Phone: ${order['userPhone'] ?? 'Not provided'}',
                    style: GoogleFonts.poppins(
                      color: order['userPhone'] != null ? Colors.blue : null,
                      decoration: order['userPhone'] != null ? TextDecoration.underline : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // Place
            Row(
              children: [
                Icon(Icons.place, size: 16, color: _primaryColor),
                const SizedBox(width: 4),
                Text(
                  'Place: ${order['place'] ?? 'Not specified'}',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Time
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: _primaryColor),
                const SizedBox(width: 4),
                Text(
                  'Time: ${order['time'] ?? 'Not specified'}',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            
            // Action Buttons for Pending Orders
            if (_orderStatus == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _updateOrderStatus(orderId, 'accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      "Accept",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _updateOrderStatus(orderId, 'rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      "Reject",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}