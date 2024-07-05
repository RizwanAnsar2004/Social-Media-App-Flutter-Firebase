import 'package:flutter/material.dart';
import 'package:moneyup/models/user.dart';
import 'package:moneyup/views/register_view.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final RegisterView _auth = RegisterView();
  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _auth.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
