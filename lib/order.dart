import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_controller.dart';
import 'my_orders_screen.dart';

class OrderScreen extends StatefulWidget {
  final Map<String, dynamic> seller;

  const OrderScreen({required this.seller, super.key});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _placeController = TextEditingController();
  final _timeController = TextEditingController();
  final _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _reviewFormKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  double _rating = 0.0;
  
  final Color primaryColor = const Color(0xFF89AC46);
  final Color darkPrimaryColor = const Color(0xFF6E8D38);
  final Color backgroundColor = const Color(0xFFF5F5F5);

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    _timeController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _submitOrder(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final userController = Provider.of<UserController>(context, listen: false);
      final userId = userController.user['uid'] ?? 'Unknown ID';
      final userName = userController.user['username'] ?? 'Unknown User';
      final userPhone = userController.user['telephone'] ?? '';

      final orderDoc = FirebaseFirestore.instance.collection('orders').doc();
      await orderDoc.set({
        'orderId': orderDoc.id,
        'sellerName': widget.seller['name'],
        'sellerService': widget.seller['service'],
        'sellerId': widget.seller['uid'] ?? 'Unknown',
        'quantity': int.parse(_quantityController.text.trim()),
        'description': _descriptionController.text.trim(),
        'place': _placeController.text.trim(),
        'time': _timeController.text.trim(),
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
        'username': userName,
        'userPhone': userPhone,
        'lastUpdated': FieldValue.serverTimestamp(),
        'notificationSeen': false,
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'recipientId': widget.seller['uid'],
        'senderId': userId,
        'type': 'new_order',
        'orderId': orderDoc.id,
        'message': 'New order request for ${widget.seller['service']}',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order submitted successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: primaryColor,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyOrdersScreen(userId: userId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red[400],
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _submitReview(BuildContext context) async {
    if (!_reviewFormKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final userController = Provider.of<UserController>(context, listen: false);
      
      await FirebaseFirestore.instance.collection('reviews').add({
        'sellerId': widget.seller['uid'],
        'userId': userController.user['uid'] ?? 'Unknown ID',
        'username': userController.user['username'] ?? 'Unknown User',
        'rating': _rating,
        'review': _reviewController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Review submitted successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: primaryColor,
        ),
      );

      _reviewController.clear();
      setState(() => _rating = 0.0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red[400],
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image - same as other screens
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/new.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Column(
            children: [
              AppBar(
                title: Text(
                  'Order from ${widget.seller['name']}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: primaryColor.withOpacity(0.8),
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Form Card
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Service: ${widget.seller['service']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildFormField(
                                  controller: _quantityController,
                                  label: 'Quantity',
                                  icon: Icons.format_list_numbered,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Please enter quantity';
                                    final quantity = int.tryParse(value);
                                    if (quantity == null || quantity <= 0) return 'Enter valid quantity';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                                _buildFormField(
                                  controller: _descriptionController,
                                  label: 'Order Description',
                                  icon: Icons.description,
                                  maxLines: 4,
                                  validator: (value) => 
                                    value == null || value.isEmpty ? 'Please enter description' : null,
                                ),
                                const SizedBox(height: 15),
                                _buildFormField(
                                  controller: _placeController,
                                  label: 'Place',
                                  icon: Icons.place,
                                  validator: (value) => 
                                    value == null || value.isEmpty ? 'Please enter place' : null,
                                ),
                                const SizedBox(height: 15),
                                _buildFormField(
                                  controller: _timeController,
                                  label: 'Time',
                                  icon: Icons.access_time,
                                  validator: (value) => 
                                    value == null || value.isEmpty ? 'Please enter time' : null,
                                ),
                                const SizedBox(height: 25),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting ? null : () => _submitOrder(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: _isSubmitting
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                            'Submit Order',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Review Form Card
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Leave a Review',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: darkPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Form(
                                key: _reviewFormKey,
                                child: Column(
                                  children: [
                                    RatingBar.builder(
                                      initialRating: _rating,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) => setState(() => _rating = rating),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildFormField(
                                      controller: _reviewController,
                                      label: 'Your Review',
                                      icon: Icons.comment,
                                      maxLines: 4,
                                      validator: (value) => 
                                        value == null || value.isEmpty ? 'Please enter review' : null,
                                    ),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: _isSubmitting ? null : () => _submitReview(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 3,
                                        ),
                                        child: _isSubmitting
                                            ? const CircularProgressIndicator(color: Colors.white)
                                            : Text(
                                                'Submit Review',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Reviews List Card
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Latest Reviews',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: darkPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 15),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('reviews')
                                    .where('sellerId', isEqualTo: widget.seller['uid'])
                                    .orderBy('timestamp', descending: true)
                                    .limit(3)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator(color: primaryColor));
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                    return Text(
                                      'No reviews yet',
                                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                                    );
                                  }
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.docs.length,
                                    separatorBuilder: (context, index) => const Divider(height: 30),
                                    itemBuilder: (context, index) {
                                      final review = snapshot.data!.docs[index];
                                      return _buildReviewCard(review);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.poppins(),
      validator: validator,
    );
  }

  Widget _buildReviewCard(QueryDocumentSnapshot review) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review['username'],
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          RatingBarIndicator(
            rating: review['rating'],
            itemCount: 5,
            itemSize: 20,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            review['review'],
            style: GoogleFonts.poppins(),
          ),
        ],
      ),
    );
  }
}