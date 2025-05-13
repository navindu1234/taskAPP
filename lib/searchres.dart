import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order.dart';

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
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('category', isGreaterThanOrEqualTo: widget.query)
          .where('category', isLessThanOrEqualTo: '${widget.query}\uf8ff')
          .get();

      List<Map<String, dynamic>> sellers = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        data['uid'] = doc.id; // Ensure seller ID is included

        // Use coverImage directly if it exists
        if (data.containsKey('coverImage') && data['coverImage'] is String) {
          // If coverImage is already a URL, use it directly
          data['coverImage'] = data['coverImage'];
        } else {
          // Fallback to placeholder if no cover image
          data['coverImage'] = 'https://via.placeholder.com/400';
        }

        // Calculate average rating and review count
        final reviewsSnapshot = await FirebaseFirestore.instance
            .collection('reviews')
            .where('sellerName', isEqualTo: data['name'])
            .get();

        double totalRating = 0;
        int reviewCount = reviewsSnapshot.docs.length;

        for (var review in reviewsSnapshot.docs) {
          totalRating += review['rating'] ?? 0;
        }

        double averageRating = reviewCount > 0 ? totalRating / reviewCount : 0.0;

        data['rating'] = averageRating;
        data['reviewsCount'] = reviewCount;

        sellers.add(data);
      }

      return sellers;
    } catch (e) {
      debugPrint('Error searching sellers: $e');
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchResults = _searchSellers();
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
                  'Results for "${widget.query}"',
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
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Error loading results: ${snapshot.error}',
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
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
                            style: GoogleFonts.poppins(
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
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderScreen(
                                    seller: seller,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15.0)),
                                  child: Image.network(
                                    seller['coverImage'] ?? 'https://via.placeholder.com/400',
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
                                    style: GoogleFonts.poppins(
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
                                            seller['rating']?.toStringAsFixed(1) ?? '0.0',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '(${seller['reviewsCount'] ?? '0'} reviews)',
                                            style: GoogleFonts.poppins(
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
                                      style: GoogleFonts.poppins(
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
                                        style: GoogleFonts.poppins(
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
                                            style: GoogleFonts.poppins(fontSize: 14.0),
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
                                      child: Text(
                                        'Order Now',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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