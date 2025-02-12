import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'nine.dart'; // Import the NineScreen
import 'eight.dart'; // Import the EightScreen

class SellerLogin extends StatefulWidget {
  const SellerLogin({super.key});

  @override
  State<SellerLogin> createState() => _SellerLoginState();
}

class _SellerLoginState extends State<SellerLogin> {
  final TextEditingController _codeController = TextEditingController();
  String? _errorMessage;
  Map<String, dynamic>? _sellerDetails;

  // Function to validate the unique code from Firestore
  Future<bool> _validateUniqueCode(String code) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('uniqueCode', isEqualTo: code)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If code is found, get the first document's data
        _sellerDetails = querySnapshot.docs.first.data();
        return true; // Valid code
      } else {
        return false; // Invalid code
      }
    } catch (e) {
      return false; // Error while querying Firestore
    }
  }

  void _login() async {
    final code = _codeController.text.trim();
    setState(() {
      _errorMessage = null;
    });

    final isValid = await _validateUniqueCode(code);

    if (isValid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NineScreen(sellerDetails: _sellerDetails!), // Pass seller details to next screen
        ),
      );
    } else {
      setState(() {
        _errorMessage = "Invalid unique code. Please try again.";
      });
    }
  }

  void _createSellerAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EightScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Login'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Your Unique Code:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Unique Code',
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: _login,
                child: const Text('Login'),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: _createSellerAccount,
                child: const Text('Create Seller Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
