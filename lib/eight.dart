import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'sellerlog.dart'; // Import SellerLogin screen

class EightScreen extends StatefulWidget {
  const EightScreen({super.key});

  @override
  _EightScreenState createState() => _EightScreenState();
}

class _EightScreenState extends State<EightScreen> {
  final _nameController = TextEditingController();
  final _serviceController = TextEditingController();
  final _addressController = TextEditingController();  // New address controller
  final _educationController = TextEditingController();  // New education controller
  final _ageController = TextEditingController();  // New age controller
  final _cityController = TextEditingController();  // New city controller
  
  String _selectedCategory = 'House Cleaning';
  
  final _categories = ['House Cleaning', 'Garage Labor', 'Electrician'];

  void _registerSeller() async {
    final name = _nameController.text.trim();
    final service = _serviceController.text.trim();
    final address = _addressController.text.trim();
    final education = _educationController.text.trim();
    final age = _ageController.text.trim();
    final city = _cityController.text.trim();

    if (name.isEmpty || service.isEmpty || address.isEmpty || education.isEmpty || age.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields'),
      ));
      return;
    }

    // Generate a unique 5-digit code
    final random = Random();
    final uniqueCode = random.nextInt(90000) + 10000;

    try {
      // Save seller data to Firestore
      await FirebaseFirestore.instance.collection('services').add({
        'name': name,
        'service': service,
        'category': _selectedCategory,
        'uniqueCode': uniqueCode.toString(),
        'address': address,
        'education': education,
        'age': age,
        'city': city,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Navigate back to SellerLogin screen with a success message
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SellerLogin()),
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration successful! Your unique code: $uniqueCode'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Seller'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _serviceController,
              decoration: const InputDecoration(labelText: 'Service'),
            ),
            TextField(
              controller: _addressController,  // Address field
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _educationController,  // Education field
              decoration: const InputDecoration(labelText: 'Educational Qualifications'),
            ),
            TextField(
              controller: _ageController,  // Age field
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            TextField(
              controller: _cityController,  // City field
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedCategory,
              items: _categories
                  .map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _registerSeller,
              child: const Text('Register as Seller'),
            ),
          ],
        ),
      ),
    );
  }
}
