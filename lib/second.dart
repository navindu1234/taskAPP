import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fifth.dart'; // Import the FifthScreen file

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    Future<void> loginUser() async {
      final username = usernameController.text;
      final password = passwordController.text;

      try {
        // Query Firestore for username and password
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .where('password', isEqualTo: password)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the first matched user data
          final user = querySnapshot.docs.first.data();

          // Navigate to FifthScreen with user data
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FifthScreen(user: user), // Pass user data
            ),
          );
        } else {
          // Show error if no user found
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid username or password')));
        }
      } catch (e) {
        // Handle Firestore errors
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error logging in: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        backgroundColor: const Color(0xFF5D8736), // Updated AppBar color
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/new.png'), // Your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome Back!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24, // Slightly larger text size
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA9C46C)), // Updated text color
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Color(0xFFA9C46C)), // Olive color for label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded border
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA9C46C)),
                  ),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFFA9C46C)), // Olive color for icons
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Color(0xFFA9C46C)), // Olive color for label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded border
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA9C46C)),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFFA9C46C)), // Olive color for icons
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D8736), // Muted green color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded button
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shadowColor: Colors.black, // Subtle shadow for better depth
                  elevation: 5, // Elevation for modern look
                ),
                onPressed: loginUser,
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Navigate back or show forgot password
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                      color: Color(0xFFA9C46C), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
