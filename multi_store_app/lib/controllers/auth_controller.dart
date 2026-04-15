import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:multi_store_app/global_variables.dart';
import 'package:multi_store_app/models/user.dart';
import 'package:multi_store_app/provider/user_provider.dart';
import 'package:multi_store_app/services/manage_http_response.dart';
import 'package:multi_store_app/views/screens/authentication_screens/login_screen.dart';
import 'package:multi_store_app/views/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final providerContainer = ProviderContainer();

class AuthController {
  Future<void> signUpUsers({
    required BuildContext context,
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      print("SIGNUP FUNCTION CALLED");
      User user = User(
        id: '',
        fullName: fullName,
        email: email,
        state: '',
        city: '',
        locality: '',
        password: password,
        token: '',
      );
      print("SENDING HTTP REQUEST");
      http.Response response = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print("RESPONSE RECEIVED");
      print(response.statusCode);
      print(response.body);
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          showSnackBar(context, 'Account has been Created for you');
        },
      );
    } catch (e) {
      print("Error : $e");
    }
  }

  Future<void> signInUsers({
    required context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("$uri/api/signin"),
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8', // ADDED THIS LINE
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          //Access sharedPreferences for token and user data storage
          SharedPreferences preferences = await SharedPreferences.getInstance();
          //Extract the authentication token from the response body
          String token = jsonDecode(response.body)['token'];
          //store the authentication token securely in sharedPreferences
          await preferences.setString('auth_token', token);
          //encode the user data recived from the backend json
          final userJson = jsonEncode(jsonDecode(response.body)['user']);
          //update the application state with user data using Riverpod
          providerContainer.read(userProvider.notifier).setUser(userJson);
          //store the data in sharedPreferences for future use
          await preferences.setString('user', userJson);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
          showSnackBar(context, 'Logged In');
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  //Signout
  Future<void> signOutUser({required context}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      //clear the token and user from SharedPreferences
      await preferences.remove('auth_token');
      await preferences.remove('user');
      //clear the user state
      providerContainer.read(userProvider.notifier).signOut();
      //navigate the user back to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
        ),
        (route) => false,
      );
      showSnackBar(context, 'Signout successfully');
    } catch (e) {
      showSnackBar(context, 'Error signing out');
    }
  }

  //Update user's state, city and locality
  Future<void> updateUserLocation({
    required context,
    required String id,
    required String state,
    required String city,
    required String locality,
  }) async {
    try {
      //take an HTTP PUT request to update user's state, city and locality
      final http.Response response = await http.put(
        Uri.parse('$uri/api/users/$id'),
        //Set the headers for the request to specify that the content is Json
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        //Encode the updated data(state,city and locality) as JSON object
        body: jsonEncode({'state': state, "city": city, "locality": locality}),
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          //Decode the updated user data from the response body
          //This converts the json String response into Dart Map
          final updatedUser = jsonDecode(response.body);
          //Access Shared Preference for local data storage
          //Shared preference allow us to store data presistently on the device
          SharedPreferences preferences = await SharedPreferences.getInstance();
          //Encode the updated user data as json String
          //this prepared the data for storage in shared preference
          final userJson = jsonEncode(updatedUser);
          //update the application state with the updated user data using Riverpod
          //this ensures the app reflects the most recent user data
          providerContainer.read(userProvider.notifier).setUser(userJson);
          //store the updated user data in shared preference for future user
          //this allows the app to retrive the user data even after the app restarts
          await preferences.setString('user', userJson);
        },
      );
    } catch (e) {
      //catch any error that occurs during the proccess
      //Show an error message to the user if the update fails
      showSnackBar(context, 'Error updating location');
    }
  }
}
