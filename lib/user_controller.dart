import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {
  Map<String, dynamic> _user = {};
  

  Map<String, dynamic> get user => _user;

  get username => null;

  void setUser(Map<String, dynamic> userData) {
    _user = userData;
    notifyListeners();
  }

  void clearUser() {
    _user = {};
    notifyListeners();
  }
}
