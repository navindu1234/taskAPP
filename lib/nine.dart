import 'package:flutter/material.dart';
//sellerdetails


class NineScreen extends StatelessWidget {
  final Map<String, dynamic> sellerDetails;

  const NineScreen({super.key, required this.sellerDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Details'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Title section
            const Center(
              child: Text(
                'Seller Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Seller Details Card
            Card(
              margin: const EdgeInsets.only(bottom: 20),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          'Name: ${sellerDetails['name']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Service
                    Row(
                      children: [
                        const Icon(Icons.build, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          'Service: ${sellerDetails['service']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Category
                    Row(
                      children: [
                        const Icon(Icons.category, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          'Category: ${sellerDetails['category']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Unique Code
                    Row(
                      children: [
                        const Icon(Icons.code, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          'Unique Code: ${sellerDetails['uniqueCode']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Address
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          'Address: ${sellerDetails['address']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Education
                    Row(
                      children: [
                        const Icon(Icons.school, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          'Education: ${sellerDetails['education']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Age
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          'Age: ${sellerDetails['age']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // City
                    Row(
                      children: [
                        const Icon(Icons.location_city, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          'City: ${sellerDetails['city']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons (optional)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Action when button is pressed (e.g., Edit or View more details)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                child: const Text(
                  'Edit Seller Details',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
