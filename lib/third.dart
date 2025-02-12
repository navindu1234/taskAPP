import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// user registration
class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  // Controllers for form fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController secondNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Key to validate form

  // Save data to Firestore
  Future<void> saveData() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Generate a unique user ID
        final String userId = FirebaseFirestore.instance.collection('users').doc().id;

        // Save data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'userId': userId,
          'firstName': firstNameController.text,
          'secondName': secondNameController.text,
          'address': addressController.text,
          'phone': phoneController.text,
          'username': usernameController.text,
          'password': passwordController.text, // Do not store plain passwords in production
        });

        // Clear the form after saving
        firstNameController.clear();
        secondNameController.clear();
        addressController.clear();
        phoneController.clear();
        usernameController.clear();
        passwordController.clear();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create account: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create an Account'),
        backgroundColor: const Color(0xFF5D8736), // Updated AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Register Below',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24, // Increased font size
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA9C46C), // Olive green text
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: const TextStyle(color: Color(0xFFA9C46C)), // Olive color for label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded borders
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA9C46C)),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Enter first name' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: secondNameController,
                decoration: InputDecoration(
                  labelText: 'Second Name',
                  labelStyle: const TextStyle(color: Color(0xFFA9C46C)), // Olive color for label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded borders
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA9C46C)),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Enter second name' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: const TextStyle(color: Color(0xFFA9C46C)), // Olive color for label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded borders
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA9C46C)),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Telephone Number',
                  labelStyle: const TextStyle(color: Color(0xFFA9C46C)), // Olive color for label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded borders
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA9C46C)),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter phone number';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Color(0xFFA9C46C)), // Olive color for label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded borders
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA9C46C)),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Enter username' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Color(0xFFA9C46C)), // Olive color for label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded borders
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA9C46C)),
                  ),
                ),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D8736), // Muted green color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded button
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shadowColor: Colors.black, // Subtle shadow for depth
                  elevation: 5, // Elevation for modern feel
                ),
                onPressed: saveData,
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
