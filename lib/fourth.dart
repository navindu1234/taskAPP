import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'seven.dart';  // Notifications page
import 'searchres.dart';  // Import the Search Results page
import 'fifth.dart';  // Import FifthPage

class FourthPage extends StatefulWidget {
  const FourthPage({super.key});

  @override
  State<FourthPage> createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  int _selectedIndex = 0;
  TextEditingController searchController = TextEditingController();
  final List<String> _categories = ['House Cleaning', 'Garage Labor', 'Electrician'];
  List<String> _filteredCategories = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index for highlighting
    });

    // Navigate to respective pages
    switch (index) {
      case 0:
        // Stay on the current screen (Home)
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SevenScreen()),
        );
        break;
      case 2:  // Navigate to FifthPage (Profile)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FifthScreen(user: {},)),
        );
        break;
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredCategories = _categories
          .where((category) => category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> sliderImages = [
      'assets/sdimage1.png',
      'assets/sdimage2.png',
      'assets/sdimage3.png',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF5D8736), // Olive Green
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/new.png'), // Your background image
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search for services...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF5D8736)), // Olive Green
                    filled: true,
                    fillColor: const Color(0xFFA9C46C), // Light Olive
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ),

              // Category Suggestions
              if (searchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: _filteredCategories
                        .map((category) => ListTile(
                              title: Text(category),
                              onTap: () {
                                // Navigate to the Search Results page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchResScreen(query: category),
                                  ),
                                );
                              },
                            ))
                        .toList(),
                  ),
                ),

              // Image Slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CarouselSlider.builder(
                  itemCount: sliderImages.length,
                  itemBuilder: (context, index, realIndex) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(sliderImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                  ),
                ),
              ),

              // Detail Cards with category names
              const DetailCard(imagePath: 'assets/image1.png', cardTitle: 'House Cleaning', searchQuery: 'House Cleaning'),
              const DetailCard(imagePath: 'assets/image2.png', cardTitle: 'Garage Labor', searchQuery: 'Garage Labor'),
              const DetailCard(imagePath: 'assets/image3.png', cardTitle: 'Electrician', searchQuery: 'Electrician'),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF5D8736), // Olive Green
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DetailCard extends StatelessWidget {
  final String imagePath;
  final String cardTitle;
  final String searchQuery; // Pass the query for search navigation

  const DetailCard({required this.imagePath, required this.cardTitle, required this.searchQuery, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to the search results page with the respective category
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResScreen(query: searchQuery),
            ),
          );
        },
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            cardTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
