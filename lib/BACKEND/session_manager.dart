import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../user_controller.dart';

class SessionManager {
  static Future<bool> checkUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    
    // If username is stored, user was logged in
    if (username != null && username.isNotEmpty) {
      // Try to restore user data from Firestore
      return await _restoreUserSession(username);
    }
    
    return false;
  }
  
  static Future<bool> _restoreUserSession(String username) async {
    try {
      final userController = Get.find<UserController>();
      
      // Get user data from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        // Add document ID to user data
        userData['uid'] = querySnapshot.docs.first.id;
        
        // Restore user data to controller
        userController.setUser(userData);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error restoring session: $e');
      return false;
    }
  }
  
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clear stored username
      await prefs.remove('username');
      
      // Clear user controller data
      final userController = Get.find<UserController>();
      userController.clearUser();
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}