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
          builder: (context) => SellerDetailsScreen(sellerDetails: _sellerDetails!),
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
        title: const Text('Seller Login', style: TextStyle(color: Colors.white)),
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Your Unique Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _codeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Unique Code',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Enter your seller code',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.blue[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.blue[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  prefixIcon: const Icon(Icons.code, color: Colors.white70),
                  errorText: _errorMessage,
                  errorStyle: TextStyle(color: Colors.red[200]),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                onPressed: _login,
                child: const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
                onPressed: _createSellerAccount,
                child: const Text(
                  'Create Seller Account',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}