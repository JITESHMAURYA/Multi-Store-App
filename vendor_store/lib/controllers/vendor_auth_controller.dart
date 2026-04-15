import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_store/global_variables.dart';
import 'package:vendor_store/models/vendor.dart';
import 'package:http/http.dart' as http;
import 'package:vendor_store/provider/vendor_provider.dart';
import 'package:vendor_store/services/manage_http_response.dart';
import 'package:vendor_store/views/screens/main_vendor_screen.dart';

final providerContainer = ProviderContainer();

class VendorAuthController {
  Future<void> signUpVendor({
    required String fullName,
    required String email,
    required String password,
    required context,
  }) async {
    try {
      Vendor vendor = Vendor(
        id: '',
        fullName: fullName,
        email: email,
        state: '',
        city: '',
        locality: '',
        role: '',
        password: password,
      );
      http.Response response = await http.post(
        Uri.parse("$uri/api/vendor/signup"),
        body: vendor.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Vendor Account Created");
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }

  Future<void> signInVendor({
    required String email,
    required String password,
    required context,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/vendor/signin'),
        body: jsonEncode({"email": email, "password": password}),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          //Extract the authentication token from the response body
          String token = jsonDecode(response.body)['token'];
          //Store the authentication token securely in SharedPreferences
          await preferences.setString('auth_token', token);
          //Encode the user data recived from the backend as json
          final vendorJson = jsonEncode(jsonDecode(response.body)['vendor']);
          //update the application state with the user data using riverpod
          providerContainer.read(vendorProvider.notifier).setVendor(vendorJson);
          //store the data in SharedPreferences
          await preferences.setString('vendor', vendorJson);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) {
                return MainVendorScreen();
              },
            ),
            (route) => false,
          );
          showSnackBar(context, 'Logged in successfully');
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }
}
