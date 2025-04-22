import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
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
  bool _isReviewSubmitting = false;
  double _rating = 0.0;
  List<File> _reviewImages = [];
  final ImagePicker _picker = ImagePicker();
  
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

  Future<void> _pickReviewImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        if (_reviewImages.length + pickedFiles.length > 5) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('You can upload up to 5 images'),
              backgroundColor: Colors.red[400],
            ),
          );
          return;
        }
        setState(() {
          _reviewImages.addAll(pickedFiles.map((file) => File(file.path)).toList());
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: ${e.toString()}'),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  void _removeReviewImage(int index) {
    setState(() {
      _reviewImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadReviewImages() async {
    List<String> imageUrls = [];
    if (_reviewImages.isEmpty) return imageUrls;

    try {
      for (var image in _reviewImages) {
        final String fileName = 'reviews/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
        final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
        final UploadTask uploadTask = storageRef.putFile(image);
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
    } catch (e) {
      debugPrint('Error uploading images: $e');
      throw Exception('Failed to upload images');
    }
    return imageUrls;
  }

  Future<void> _submitOrder(BuildContext context) async {
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

      if (!mounted) return;
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

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyOrdersScreen(userId: userId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting order: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red[400],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitReview(BuildContext context) async {
    if (!_reviewFormKey.currentState!.validate()) return;
    if (_rating == 0.0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please provide a rating'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    setState(() => _isReviewSubmitting = true);

    try {
      final userController = Provider.of<UserController>(context, listen: false);
      final List<String> imageUrls = await _uploadReviewImages();
      
      await FirebaseFirestore.instance.collection('reviews').add({
        'sellerName': widget.seller['name'],
        'userId': userController.user['uid'] ?? 'Unknown ID',
        'username': userController.user['username'] ?? 'Unknown User',
        'rating': _rating,
        'review': _reviewController.text.trim(),
        'images': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'service': widget.seller['service'],
      });

      await _updateSellerRating();

      if (!mounted) return;
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
      setState(() {
        _rating = 0.0;
        _reviewImages = [];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting review: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red[400],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isReviewSubmitting = false);
      }
    }
  }

  Future<void> _updateSellerRating() async {
    try {
      final reviewsQuery = FirebaseFirestore.instance
          .collection('reviews')
          .where('sellerName', isEqualTo: widget.seller['name']);

      final reviewsSnapshot = await reviewsQuery.get();

      double totalRating = 0;
      int reviewCount = reviewsSnapshot.docs.length;

      for (var review in reviewsSnapshot.docs) {
        totalRating += review['rating'] ?? 0;
      }

      double averageRating = reviewCount > 0 ? totalRating / reviewCount : 0.0;

      await FirebaseFirestore.instance
          .collection('services')
          .doc(widget.seller['uid'])
          .update({
            'rating': averageRating,
            'reviewsCount': reviewCount,
          });
    } catch (e) {
      debugPrint('Error updating seller rating: $e');
      throw Exception('Failed to update seller rating');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/new.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
                      // Seller Info Card
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
                              // Profile Image
                              if (widget.seller['profileImage'] != null)
                                Center(
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(widget.seller['profileImage']),
                                  ),
                                ),
                              const SizedBox(height: 15),
                              
                              Text(
                                widget.seller['name'] ?? 'No Name',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: darkPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              
                              // Rating and Reviews
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.seller['rating']?.toStringAsFixed(1) ?? '0.0',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${widget.seller['reviewsCount'] ?? '0'} reviews)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              
                              // Seller Details
                              _buildSellerDetail('Service', widget.seller['service']),
                              _buildSellerDetail('Category', widget.seller['category']),
                              _buildSellerDetail('Age', widget.seller['age']?.toString()),
                              _buildSellerDetail('City', widget.seller['city']),
                              _buildSellerDetail('Address', widget.seller['address']),
                              _buildSellerDetail('Preferred Location', widget.seller['preferredLocation']),
                              _buildSellerDetail('Work Type', widget.seller['workType']),
                              _buildSellerDetail('Experience', widget.seller['experience']),
                              _buildSellerDetail('Education', widget.seller['education']),
                              
                              // Certification
                              if (widget.seller['hasCertifications'] == true)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      'Certifications:',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (widget.seller['certificationImage'] != null)
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Scaffold(
                                                appBar: AppBar(
                                                  title: const Text('Certification'),
                                                ),
                                                body: Center(
                                                  child: Image.network(widget.seller['certificationImage']),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Image.network(
                                            widget.seller['certificationImage'],
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Order Form
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
                                  'Place Your Order',
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
                      const SizedBox(height: 20),
                      
                      // Review Form
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
                                    const SizedBox(height: 15),
                                    // Image upload section
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Add Photos (Optional - Max 5)',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (_reviewImages.isNotEmpty)
                                          SizedBox(
                                            height: 100,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: _reviewImages.length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: Image.file(
                                                          _reviewImages[index],
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: GestureDetector(
                                                          onTap: () => _removeReviewImage(index),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color: Colors.black.withOpacity(0.5),
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: const Icon(
                                                              Icons.close,
                                                              color: Colors.white,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: _reviewImages.length >= 5 
                                              ? null 
                                              : _pickReviewImages,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _reviewImages.length >= 5 
                                                ? Colors.grey[300] 
                                                : Colors.grey[200],
                                            foregroundColor: Colors.grey[800],
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.add_a_photo, 
                                                size: 18,
                                                color: _reviewImages.length >= 5 
                                                    ? Colors.grey[500] 
                                                    : Colors.grey[800],
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Add Photos (${_reviewImages.length}/5)',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: _reviewImages.length >= 5 
                                                      ? Colors.grey[500] 
                                                      : Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: _isReviewSubmitting ? null : () => _submitReview(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 3,
                                        ),
                                        child: _isReviewSubmitting
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
                      const SizedBox(height: 20),
                      
                      // Reviews List
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Customer Reviews',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: darkPrimaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Latest 5 Reviews',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'For ${widget.seller['service']} by ${widget.seller['name']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildReviewsList(),
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

  Widget _buildSellerDetail(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
Widget _buildReviewsList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('reviews')
        .where('sellerName', isEqualTo: widget.seller['']) // Fixed query to use seller's name
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(color: primaryColor),
        );
      }

      if (snapshot.hasError) {
        return _buildErrorWidget('Failed to load reviews. Please try again later.');
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return _buildEmptyStateWidget('No reviews yet. Be the first to review!');
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
  );
}

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.red[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
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
    final List<dynamic> images = review['images'] ?? [];
    
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review['username'] ?? 'Anonymous',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatDate(review['timestamp']?.toDate()),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RatingBarIndicator(
            rating: review['rating']?.toDouble() ?? 0.0,
            itemCount: 5,
            itemSize: 20,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            review['review'] ?? '',
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 8),
          // Display review images if they exist
          if (images.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Photos:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            images[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: primaryColor,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          if (review['service'] != null)
            Text(
              'Service: ${review['service']}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}