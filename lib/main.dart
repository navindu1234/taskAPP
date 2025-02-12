import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'second.dart'; // Import second.dart (LoginPage)
import 'third.dart'; // Import third.dart (ThirdPage or Registration page)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization for both mobile and web
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAao2zF5EpQZtC6gDVsWA39Z4o0FlPvKWo",
        projectId: "project-3rdyear",
        storageBucket: "project-3rdyear.appspot.com",
        messagingSenderId: "1051586925241",
        appId: "1:1051586925241:web:d6b53a277a4e14e6e50168",
      ),
    );
    print("Firebase Initialized");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TASKNEST',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'RobotoSlab', // Set default font to RobotoSlab
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extends the body behind the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove app bar shadow
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/new.png'), // Full background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo with improved padding and shadow
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                    'assets/logo.png', // Your logo in the assets folder
                    height: 150,
                  ),
                ),
                const SizedBox(height: 20),

                // Title text with enhanced font styling
                const Text(
                  'Your Trusted Service Provider',
                  style: TextStyle(
                    fontSize: 20, // Increased font size
                    fontWeight: FontWeight.bold, // Bold text
                    color: Colors.white,
                    fontFamily: 'RobotoSlab', // Use RobotoSlab font
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Login button with improved style
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(182, 87, 172, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18.0, // Increased vertical padding
                      horizontal: 40.0, // Increased horizontal padding
                    ),
                    shadowColor: Colors.black, // Adding shadow
                    elevation: 8.0, // Added elevation for 3D effect
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                // Create Account button with improved design
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ThirdPage()),
                    );
                  },
                  child: const Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // Bold text for emphasis
                      color: Color.fromARGB(182, 106, 87, 212),
                      fontFamily: 'RobotoSlab', // Use RobotoSlab font
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
