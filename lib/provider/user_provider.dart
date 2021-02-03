import 'package:flutter/widgets.dart';
import 'package:tubes_skype/models/users_data.dart';
import 'package:tubes_skype/resources/auth_methods.dart';

class UserProvider with ChangeNotifier{
  UsersData _user;
  AuthMethods _authMethods = AuthMethods();

  UsersData get getUsersData => _user;

  void refreshUser() async {
    UsersData user = await _authMethods.getUserDetails();
    _user  = user;
    notifyListeners();
  }
}