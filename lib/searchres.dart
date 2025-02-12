import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'order.dart';  // Import the OrderScreen

class SearchResScreen extends StatefulWidget {
  final String query;

  const SearchResScreen({required this.query, super.key});

  @override
  _SearchResScreenState createState() => _SearchResScreenState();
}

class _SearchResScreenState extends State<SearchResScreen> {
  late Future<List<Map<String, dynamic>>> _searchResults;

  // Search function to find sellers by name or category
  Future<List<Map<String, dynamic>>> _searchSellers() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('services')
        .where('category', isGreaterThanOrEqualTo: widget.query)
        .where('category', isLessThanOrEqualTo: '${widget.query}\uf8ff')
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchResults = _searchSellers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        backgroundColor: const Color(0xFF5D8736), // Match theme color
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(  // Displaying the search results
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No results found.'));
          }

          final results = snapshot.data!;

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final seller = results[index];

              return Card(
                margin: const EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 5,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  title: Text(
                    seller['name'],
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Category: ${seller['category']}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 16.0,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${seller['service']}',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'City: ${seller['city']}',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Address: ${seller['address']}',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D8736), // Green color matching theme
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                        onPressed: () {
                          // Pass the seller and userId to the OrderScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderScreen(
                                userId: 'user_id_example', // Replace with actual user ID
                                seller: seller,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Order Now',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
