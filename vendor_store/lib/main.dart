import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_store/provider/vendor_provider.dart';
import 'package:vendor_store/views/screens/authentication/login_screen.dart';
import 'package:vendor_store/views/screens/main_vendor_screen.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> checkTokenAndSetUser(WidgetRef ref) async {
      //Obtain an instance of SharedPreference
      SharedPreferences preferences = await SharedPreferences.getInstance();
      //retrive the authentication token and user data stored locally
      String? token = preferences.getString('auth_token');
      String? vendorJson = preferences.getString('vendor');
      //if both the token and data are available, update the vendor state
      if (token != null && vendorJson != null) {
        ref.read(vendorProvider.notifier).setVendor(vendorJson);
      } else {
        ref.read(vendorProvider.notifier).signOut();
      }
    }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder(
        future: checkTokenAndSetUser(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final vendor = ref.watch(vendorProvider);
          return vendor != null ? MainVendorScreen() : LoginScreen();
        },
      ),
    );
  }
}
