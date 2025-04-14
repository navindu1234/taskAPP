import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'second.dart'; // LoginPage
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();
  String? selectedGender;
  String? selectedUserType;
  bool agreedToTerms = false;
  File? profileImage;
  bool _isLoading = false; // Loading state

  // Color scheme from FifthScreen
  final Color primaryColor = const Color(0xFF89AC46);
  final Color darkPrimaryColor = const Color(0xFF6E8D38);
  final Color lightPrimaryColor = const Color(0xFFA8C973);
  final Color backgroundColor = const Color(0xFFF8F9F5);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return; // Validate form fields
    if (!agreedToTerms) {
      Get.snackbar('Error', 'You must agree to the Terms & Conditions',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true); // Start loading

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final username = usernameController.text.trim();
    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();
    final dob = dobController.text.trim();
    final address = addressController.text.trim();

    if (password != confirmPassword) {
      Get.snackbar('Error', 'Passwords do not match',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Check if username already exists
      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      if (existingUser.docs.isNotEmpty) {
        Get.snackbar('Error', 'Username already exists',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        setState(() => _isLoading = false);
        return;
      }

      // Create user in Firebase Auth
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'username': username,
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'dob': dob,
        'address': address,
        'gender': selectedGender,
        'userType': selectedUserType,
        'profileImage': profileImage?.path,
      });

      // Show success message
      Get.snackbar('Success', 'Registration successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      // Navigate to LoginPage after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Error registering user',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false); // Stop loading
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      [TextInputType keyboardType = TextInputType.text, bool obscureText = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            label == 'Gender' ? Icons.transgender : Icons.person_pin,
            color: primaryColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
        dropdownColor: Colors.white,
        value: selectedValue,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image (same as FifthScreen)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/new.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                AppBar(
                  title: const Text('Registration', style: TextStyle(color: Colors.white)),
                  backgroundColor: primaryColor.withOpacity(0.8),
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: profileImage != null
                                  ? Image.file(profileImage!, fit: BoxFit.cover)
                                  : Container(
                                      color: Colors.white.withOpacity(0.7),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 40,
                                        color: primaryColor,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(fullNameController, 'Full Name', Icons.person),
                        _buildTextField(usernameController, 'Username', Icons.person_outline),
                        _buildTextField(emailController, 'Email', Icons.email, TextInputType.emailAddress),
                        _buildTextField(phoneController, 'Phone', Icons.phone, TextInputType.phone),
                        _buildTextField(passwordController, 'Password', Icons.lock, TextInputType.visiblePassword, true),
                        _buildTextField(confirmPasswordController, 'Confirm Password', Icons.lock_outline, TextInputType.visiblePassword, true),
                        _buildTextField(dobController, 'Date of Birth', Icons.calendar_today, TextInputType.datetime),
                        _buildTextField(addressController, 'Address', Icons.location_on, TextInputType.streetAddress),
                        _buildDropdown('Gender', ['Male', 'Female', 'Other'], selectedGender, (value) {
                          setState(() => selectedGender = value);
                        }),
                        _buildDropdown('User Type', ['Buyer', 'Seller'], selectedUserType, (value) {
                          setState(() => selectedUserType = value);
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Checkbox(
                                value: agreedToTerms,
                                activeColor: primaryColor,
                                onChanged: (value) => setState(() => agreedToTerms = value!),
                              ),
                              const Expanded(
                                child: Text(
                                  'I agree to the Terms & Conditions',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 4,
                              shadowColor: darkPrimaryColor.withOpacity(0.5),
                            ),
                            onPressed: _isLoading ? null : registerUser,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Register',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            'Already have an account? Login',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}