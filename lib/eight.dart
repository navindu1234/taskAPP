import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'sellerlog.dart'; // Import SellerLogin screen

class EightScreen extends StatefulWidget {
  const EightScreen({super.key});

  @override
  _EightScreenState createState() => _EightScreenState();
}

class _EightScreenState extends State<EightScreen> {
  final _nameController = TextEditingController();
  final _serviceDescriptionController = TextEditingController(); // Renamed from _serviceController
  final _phoneController = TextEditingController(); // Added for telephone number
  final _addressController = TextEditingController();
  final _educationController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  final _preferredLocationController = TextEditingController();

  String _selectedCategory = 'House Cleaning';
  String _selectedExperience = '<1 year';
  String _hasCertifications = 'No';
  String _workType = 'Individual';

  final _categories = [
    'House Cleaning',
    'Garage Labor',
    'Electrician',
    'Gardening Services',
    'Pest Control',
    'Moving and Packing Services',
    'Laundry and Ironing Services',
    'House Painting Services',
    'Car Repairs and Maintenance',
    'Cooking Services',
    'Home Renovation Services',
  ];

  final _experienceLevels = [
    '<1 year',
    '1-3 years',
    '3-5 years',
    '5+ years',
  ];

  final _certificationOptions = ['Yes', 'No'];
  final _workTypeOptions = ['Individual', 'Team'];

  XFile? _profileImage;
  XFile? _coverImage;
  XFile? _certificationImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isProfile) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = pickedFile;
        } else if (_hasCertifications == 'Yes') {
          _certificationImage = pickedFile;
        } else {
          _coverImage = pickedFile;
        }
      });
    }
  }

  Future<String> uploadImageToStorage(XFile? image) async {
    if (image == null) return '';
    return 'image_url'; // Placeholder return
  }

  void _registerSeller() async {
    final name = _nameController.text.trim();
    final serviceDescription = _serviceDescriptionController.text.trim(); // Renamed from service
    final phone = _phoneController.text.trim(); // Added phone
    final address = _addressController.text.trim();
    final education = _educationController.text.trim();
    final age = _ageController.text.trim();
    final city = _cityController.text.trim();
    final preferredLocation = _preferredLocationController.text.trim();

    if (name.isEmpty || 
        serviceDescription.isEmpty || 
        phone.isEmpty || // Added phone validation
        address.isEmpty || 
        education.isEmpty || 
        age.isEmpty || 
        city.isEmpty || 
        preferredLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final random = Random();
    final uniqueCode = random.nextInt(90000) + 10000;

    String profileImageUrl = await uploadImageToStorage(_profileImage);
    String coverImageUrl = await uploadImageToStorage(_coverImage);
    String certificationImageUrl = _hasCertifications == 'Yes' 
      ? await uploadImageToStorage(_certificationImage)
      : '';

    try {
      await FirebaseFirestore.instance.collection('services').add({
        'name': name,
        'serviceDescription': serviceDescription, // Renamed from service
        'phone': phone, // Added phone
        'category': _selectedCategory,
        'uniqueCode': uniqueCode.toString(),
        'address': address,
        'education': education,
        'age': age,
        'city': city,
        'experience': _selectedExperience,
        'hasCertifications': _hasCertifications,
        'certificationImage': certificationImageUrl,
        'workType': _workType,
        'preferredLocation': preferredLocation,
        'profileImage': profileImageUrl,
        'coverImage': coverImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SellerLogin()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful! Your unique code: $uniqueCode'),
          backgroundColor: Colors.blue[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Seller', style: TextStyle(color: Colors.white)),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seller Registration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              
              // Image Upload Section
              Card(
                color: Colors.blue[800],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Upload Your Photos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => _pickImage(true),
                                child: const Text(
                                  'Profile Photo',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_profileImage != null)
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: FileImage(File(_profileImage!.path)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => _pickImage(false),
                                child: const Text(
                                  'Cover Photo',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_coverImage != null)
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: FileImage(File(_coverImage!.path)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Personal Information Section
              Card(
                color: Colors.blue[800],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_nameController, 'Full Name', Icons.person),
                      _buildTextField(_serviceDescriptionController, 'Service Description', Icons.description), // Renamed from Service
                      _buildTextField(_phoneController, 'Telephone Number', Icons.phone), // Added phone field
                      _buildTextField(_addressController, 'Address', Icons.location_on),
                      _buildTextField(_educationController, 'Education', Icons.school),
                      _buildTextField(_ageController, 'Age', Icons.calendar_today),
                      _buildTextField(_cityController, 'City', Icons.location_city),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Service Category Section
              Card(
                color: Colors.blue[800],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Category',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        dropdownColor: Colors.blue[700],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.blue[700],
                        ),
                        style: const TextStyle(color: Colors.white),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Experience Section
              Card(
                color: Colors.blue[800],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Years of Experience',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedExperience,
                        dropdownColor: Colors.blue[700],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.blue[700],
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: _experienceLevels
                            .map((level) => DropdownMenuItem<String>(
                                  value: level,
                                  child: Text(level),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedExperience = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Certifications Section
              Card(
                color: Colors.blue[800],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Professional Certifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _hasCertifications,
                        dropdownColor: Colors.blue[700],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.blue[700],
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: _certificationOptions
                            .map((option) => DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _hasCertifications = value!;
                          });
                        },
                      ),
                      if (_hasCertifications == 'Yes') ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _pickImage(false),
                          child: const Text(
                            'Upload Certification',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_certificationImage != null)
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: FileImage(File(_certificationImage!.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Work Type Section
              Card(
                color: Colors.blue[800],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Work Type',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _workType,
                        dropdownColor: Colors.blue[700],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.blue[700],
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: _workTypeOptions
                            .map((option) => DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _workType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Preferred Location Section
              Card(
                color: Colors.blue[800],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preferred Working Locations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _preferredLocationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'City/Area',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Enter your preferred locations',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          prefixIcon: const Icon(Icons.place, color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          filled: true,
                          fillColor: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Register Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    elevation: 5,
                  ),
                  onPressed: _registerSeller,
                  child: const Text(
                    'REGISTER AS SELLER',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          hintText: 'Enter your $label',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.blue[700],
        ),
        keyboardType: label == 'Telephone Number' ? TextInputType.phone : TextInputType.text, // Set keyboard type for phone
      ),
    );
  }
}