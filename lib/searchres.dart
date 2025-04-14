import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'order.dart';
import 'user_controller.dart';

class SearchResScreen extends StatefulWidget {
  final String query;

  const SearchResScreen({required this.query, super.key});

  @override
  _SearchResScreenState createState() => _SearchResScreenState();
}

class _SearchResScreenState extends State<SearchResScreen> {
  late Future<List<Map<String, dynamic>>> _searchResults;
  final Color primaryColor = const Color(0xFF89AC46);
  final Color darkPrimaryColor = const Color(0xFF6E8D38);
  final Color lightPrimaryColor = const Color(0xFFA8C973);
  final Color backgroundColor = const Color(0xFFF5F5F5);

  Future<List<Map<String, dynamic>>> _searchSellers() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('services')
        .where('category', isGreaterThanOrEqualTo: widget.query)
        .where('category', isLessThanOrEqualTo: '${widget.query}\uf8ff')
        .get();

    List<Map<String, dynamic>> sellers = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      if (data.containsKey('coverPhoto') && data['coverPhoto'] is String) {
        try {
          String imageUrl = await FirebaseStorage.instance
              .ref(data['coverPhoto'])
              .getDownloadURL();
          data['coverPhoto'] = imageUrl;
        } catch (e) {
          data['coverPhoto'] = 'https://via.placeholder.com/400';
        }
      }

      sellers.add(data);
    }

    return sellers;
  }

  @override
  void initState() {
    super.initState();
    _searchResults = _searchSellers();
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background image (same as other screens)
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
                  'Results for "${widget.query}"',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: primaryColor.withOpacity(0.8),
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _searchResults,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            'No results found for "${widget.query}"',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    }

                    final results = snapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final seller = results[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 3,
                          color: Colors.white.withOpacity(0.9),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Seller Cover Photo
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15.0)),
                                child: Image.network(
                                  seller['coverPhoto'] ?? 'https://via.placeholder.com/400',
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 180,
                                      color: lightPrimaryColor.withOpacity(0.2),
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: primaryColor.withOpacity(0.5),
                                        size: 50,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Text(
                                  seller['name'] ?? 'No Name',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${seller['rating'] ?? '0.0'}',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '(${seller['reviewsCount'] ?? '0'} reviews)',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: lightPrimaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Category: ${seller['category'] ?? 'Not specified'}',
                                    style: TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      seller['service'] ?? 'Service not specified',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            color: primaryColor, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${seller['city'] ?? 'City not specified'}',
                                          style: const TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.home, color: primaryColor, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${seller['address'] ?? 'Address not specified'}',
                                          style: const TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                                      elevation: 2,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OrderScreen(
                                            seller: seller,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Order Now',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}