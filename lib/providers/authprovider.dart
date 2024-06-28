import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  Future<bool> login(Map loginBody, context) async {
    bool isLogedIn = false;
    final response = await http.post(
        Uri.parse("http://192.168.0.108:8000/api/customer/login"),
        body: loginBody);
    debugPrint("POST ON: http://192.168.1.10:8000/api/customer/login");
    debugPrint("SENT BODY: $loginBody");
    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("POST RES: ${response.body}");

    if (response.statusCode == 200) {
      isLogedIn = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("token", json.decode(response.body)['token']);
    } else {
      isLogedIn = false;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login Failed")));
    }
    return isLogedIn;
  }

  Future<bool> register(Map registerBody, context) async {
    final response = await http.post(
      Uri.parse("http://192.168.1.10/api/customer/register"),
      body: registerBody,
    );

    debugPrint("POST ON: http://192.168.1.10/api/customer/register");
    debugPrint("SENT BODY: $registerBody");
    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("POST RES: ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorMessage =
          response.body.isNotEmpty ? response.body : "Unknown error occurred";
      debugPrint("Error message: $errorMessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $errorMessage")),
      );
      return false;
    }
  }

  Future<bool> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    return true;
  }
}
